# Deploying Recipy to Fly.io

Everything in the repo is ready. What's left needs your accounts and
credentials, so it has to be run by you. Budget about an hour for the first
deploy, most of it waiting.

Running cost at passion-project scale: **£0–5/month.** The app sleeps when
nobody is using it, and Postgres and object storage both have free allowances
that a handful of users will not exhaust.

---

## 1. Install the CLI and sign in

```bash
brew install flyctl
fly auth signup     # or: fly auth login
```

Fly asks for a card at signup. It is used for spend above the free allowance;
set a spend limit at <https://fly.io/dashboard> → Billing before you go further
so you cannot be surprised.

## 2. Create the app

```bash
fly launch --no-deploy --copy-config
```

`--copy-config` makes it use the `fly.toml` already in the repo rather than
generating a new one. Say **no** when it offers to set up Postgres or Redis —
the next step does Postgres properly.

If it reports the app name is taken, edit `app = "recipy-app"` in `fly.toml`
and re-run. The name becomes your `https://<name>.fly.dev` address.

## 3. Attach Postgres

```bash
fly postgres create --name recipy-db --region cdg --initial-cluster-size 1 \
  --vm-size shared-cpu-1x --volume-size 1
fly postgres attach recipy-db --app recipy-app
```

`attach` creates a database and user and sets `DATABASE_URL` on the app for
you — don't set it by hand.

> The smallest Postgres costs roughly $2/month once you're past the free
> allowance. `fly postgres create` is unmanaged Postgres on a volume; it is
> fine for this, but **you own the backups** — see step 8.

## 4. Object storage for recipe photos

Without this, uploaded photos are written to the container's disk and are
**deleted on every deploy**. Tigris is built into Fly and needs no separate
account:

```bash
fly storage create --name recipy-uploads
```

It prints `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ENDPOINT_URL_S3`,
`AWS_REGION` and `BUCKET_NAME`. **Read the line above them.** If it says
"Setting the following secrets on recipy-app", they are set. If it says "Set
the following secrets on your target app", flyctl has left that to you — it
does this when the app already has secrets by those names, or when the app was
not detected. In that case set them yourself, from the printed values:

```bash
fly secrets set AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... \
  AWS_ENDPOINT_URL_S3=https://fly.storage.tigris.dev AWS_REGION=auto \
  BUCKET_NAME=recipy-uploads --app recipy-app
```

Rails reads `AWS_BUCKET`, not `BUCKET_NAME`, so copy it across:

```bash
fly secrets set AWS_BUCKET=recipy-uploads --app recipy-app
```

Then confirm with `fly secrets list --app recipy-app` — six `AWS`/`BUCKET`
entries expected. A stale or missing key fails at *upload time* with
`Aws::S3::Errors::AccessDenied`, not at boot, so do not skip the check.

If you ever destroy and recreate the bucket, `fly secrets unset` the five
variables first or the new bucket's credentials will not be applied, and
Tigris holds a destroyed bucket's name for a while — pick a new one.

Cloudflare R2 works identically if you'd rather — set the same four variables.

## 5. Email for password resets

Password reset is dead without this. [Resend](https://resend.com) is free for
3,000 emails/month and takes about five minutes.

1. Sign up, add your domain, add the DNS records it gives you (SPF + DKIM).
   Without those, resets land in spam.
2. Create an API key.

```bash
fly secrets set \
  SMTP_ADDRESS=smtp.resend.com \
  SMTP_PORT=587 \
  SMTP_USERNAME=resend \
  SMTP_PASSWORD=re_your_api_key_here
```

Postmark and SendGrid work the same way — only the four values change.

## 6. Remaining secrets

```bash
fly secrets set RAILS_MASTER_KEY="$(cat config/master.key)"
fly secrets set APP_HOST=recipy-app.fly.dev   # your real domain once you have one
```

`RAILS_MASTER_KEY` decrypts `config/credentials.yml.enc`. **`config/master.key`
is gitignored — if you lose it the credentials file is unrecoverable.** Put a
copy in a password manager now.

## 7. Deploy

```bash
fly deploy
```

The release command runs `db:migrate` before the new version takes traffic; a
failed migration aborts the deploy and the old version keeps serving. Then:

```bash
fly open      # opens https://recipy-app.fly.dev
fly logs      # live logs
fly ssh console -C "/rails/bin/rails console"   # production console
```

## 8. Backups — do this before real users

`fly postgres create` gives you a database on a volume, not a managed service
with automatic backups. Daily snapshots exist but are volume-level and easy to
misread as a backup strategy. Set up a real dump:

```bash
# Verify you can take one at all:
fly postgres connect --app recipy-db
fly ssh console --app recipy-db -C "pg_dump -Fc recipy_app" > backup.dump
```

Then automate it (a scheduled machine, or a nightly `pg_dump` to object
storage). **Restore one into a scratch database before you trust it** — case
M6 in the walkthrough kit. An untested backup is not a backup.

## 9. Custom domain

```bash
fly certs add recipy.app
```

Fly prints the DNS records to add. Once the certificate is issued:

```bash
fly secrets set APP_HOST=recipy.app
```

That last step matters — `APP_HOST` drives Host authorization and the links
inside password-reset emails.

**Then move email off the test sender.** Until you have a domain, step 5 uses
Resend's shared `onboarding@resend.dev`, which only delivers to your own
address — nobody else can reset a password. Once the domain is yours:

1. In Resend, add the domain and create the SPF + DKIM records it gives you.
2. Wait for Resend to show the domain as verified.
3. `fly secrets set MAIL_FROM="Recipy <noreply@recipy.app>"`
4. Request a password reset for a non-owner account and confirm it arrives.

## 10. Optional: nutrition lookup

The nutrition panel on a recipe stays hidden until this is set —
`NutritionFetchService` returns `nil` without a key, silently. Free from
<https://fdc.nal.usda.gov/api-key-signup.html>:

```bash
fly secrets set USDA_API_KEY=your_key_here
```

## 11. Background jobs — what actually runs

Worth knowing before you wonder why emails never arrive:

- **No `queue_adapter` is configured**, so Active Job uses `:async` — an
  in-process thread pool. Nutrition fetches and `deliver_later` mail work
  with no Redis and no worker, which is why this deploy costs nothing extra.
  The trade-off is that queued jobs are **lost on restart or redeploy**. Fine
  at this scale; revisit if it starts mattering.
- **`WeeklyDigestJob` and `DailyMealPlanReminderJob` never fire on their own.**
  There is no scheduler — no sidekiq-cron, nothing in `config/sidekiq.yml`.
  They exist and work when invoked, but nothing invokes them. To turn them on
  you need either a Fly scheduled machine or sidekiq-cron plus Redis. Until
  then, treat the digest and reminder emails as not shipped.

## 12. Error monitoring

You will otherwise find out about 500s from users. [Sentry](https://sentry.io)
is free at this scale:

```ruby
# Gemfile
gem "sentry-ruby"
gem "sentry-rails"
```

```bash
fly secrets set SENTRY_DSN=https://...
```

---

## After the first deploy

Work through **section M** of the walkthrough kit against the live site, then
**section L**. Specifically:

- **L12** — visit `http://` explicitly and confirm the redirect to `https://`.
- **L11** — check the session cookie is `Secure`, `HttpOnly`, `SameSite=Lax`.
- **L15** — rate limiting is now installed; 10 bad sign-ins in 20 minutes
  should return `429`.
- **L16** — try importing `http://169.254.169.254/`; it must be refused.
- **M5** — upload a photo, `fly deploy` again, confirm the photo survives.
  This is the one that catches a missed step 4.

### Turning on CSP enforcement

The Content Security Policy ships in **report-only** mode so a mistake can't
take the site down. Open the deployed app, click through every page with the
browser console open, and look for CSP violation warnings. When there are
none:

```bash
fly secrets set CSP_ENFORCE=true
```

---

## Everyday commands

| | |
|---|---|
| `fly deploy` | Ship the current branch |
| `fly logs` | Tail production logs |
| `fly status` | Machine health |
| `fly secrets list` | Names only — values are write-once |
| `fly ssh console` | Shell into the running container |
| `fly postgres connect --app recipy-db` | psql prompt |
| `fly scale count 2` | Run two machines |
| `fly apps destroy recipy-app` | Tear the whole thing down |
