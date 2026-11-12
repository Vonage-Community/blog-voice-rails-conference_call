# Vonage Conference Call with Ruby on Rails

A small Ruby on Rails app that turns a Vonage virtual phone number into a conference line.
Everyone who calls the number hears a short greeting and joins the same conference.

The app doesn't use a Vonage SDK or a database. It only answers two
[Voice API webhooks](https://developer.vonage.com/en/voice/voice-api/webhook-reference):

| Webhook | Route | What the app does |
| --- | --- | --- |
| Answer | `GET` or `POST /webhooks/answer` | Returns an NCCO that greets and conferences callers |
| Event | `POST /webhooks/event` | Acknowledges call status updates with `200 OK` |

When someone calls your Vonage number, Vonage requests the answer URL and runs the
[Call Control Object (NCCO)](https://developer.vonage.com/en/voice/voice-api/ncco-reference)
that comes back:

```json
[
  { "action": "talk", "text": "Welcome to this Vonage conference call" },
  { "action": "conversation", "name": "vonage-conference" }
]
```

Every caller sent to a `conversation` with the same `name` joins the same conference. Names
are scoped to your Vonage application.

Read the full tutorial: [Add blog post URL once published]

## Prerequisites

- Ruby 3.2 or newer
- Rails 8.1 (installed by `bundle install`)
- Node.js 22 or newer, for the Vonage CLI
- The [Vonage CLI](https://developer.vonage.com/en/getting-started/tools/cli) v3.3 or newer
- A [Vonage API account](https://ui.idp.vonage.com/ui/auth/registration)
- A free [ngrok account](https://dashboard.ngrok.com/signup) and its authtoken. You don't need to
  install ngrok: the Vonage CLI includes it.

## Install the App

Clone the repository and install its gems:

```bash
git clone https://github.com/Vonage-Community/blog-voice-rails-conference_call.git
```

```bash
cd blog-voice-rails-conference_call
```

```bash
bundle install
```

Copy the example environment file:

```bash
cp .env.example .env
```

Open `.env` and set `NGROK_AUTHTOKEN` to the authtoken from your
[ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken). The Rails app
doesn't read this file. `vonage tunnel ngrok` loads it when you run the command from the
project root.

## Set Up Vonage with the CLI

Install the Vonage CLI:

```bash
npm install -g @vonage/cli
```

Save your API key and secret from the [Vonage Dashboard](https://dashboard.vonage.com). The
CLI checks them before saving:

```bash
vonage auth set --api-key=YOUR_API_KEY --api-secret=YOUR_API_SECRET
```

### Buy a Number

Search for a number that supports voice calls. Replace `US` with any two-letter country code:

```bash
vonage numbers search US --features=VOICE
```

Buy one of the numbers from the results. The country code comes first:

```bash
vonage numbers buy US YOUR_VONAGE_NUMBER
```

### Create a Voice Application

Create the application and note the application ID in the output:

```bash
vonage apps create "Rails Conference Call"
```

This also writes a `private.key` file to the current directory. This app doesn't need the key,
and `.gitignore` keeps it out of Git.

Add the Voice capability with the paths of the two webhooks. The `example.com` domain is a
placeholder: `vonage tunnel ngrok` replaces it with your tunnel's domain while the tunnel runs.

```bash
vonage apps capabilities update YOUR_APPLICATION_ID voice \
  --voice-answer-url=https://example.com/webhooks/answer \
  --voice-event-url=https://example.com/webhooks/event
```

Link your number to the application so calls to it reach your answer webhook:

```bash
vonage apps numbers link YOUR_APPLICATION_ID YOUR_VONAGE_NUMBER
```

## Run the App

Start the Rails server on port 3000:

```bash
bin/rails server
```

In a second terminal, from the project root, open a tunnel to port 3000:

```bash
vonage tunnel ngrok YOUR_APPLICATION_ID
```

Type `y` when the CLI asks to update the application's webhooks. It opens an ngrok tunnel,
points the application's webhooks at it, and keeps the paths you set above. Press `q` to close
the tunnel. The CLI then restores the original webhook URLs.

## Try It Out

Call your Vonage number. You hear the greeting and join the conference. Ask someone else to
call the same number, or call from a second phone, and you'll be connected to each other.

The Rails server log shows each answer request and every call status event Vonage sends.

## Run the Tests

```bash
bin/rails test
```

```bash
bin/rubocop
```

## Clean Up

When you're done, unlink and cancel the number, then delete the application, so you aren't
charged for the number:

```bash
vonage apps numbers unlink YOUR_APPLICATION_ID YOUR_VONAGE_NUMBER
```

```bash
vonage numbers cancel US YOUR_VONAGE_NUMBER
```

```bash
vonage apps delete YOUR_APPLICATION_ID
```

## Learn More

- [Connect callers to a conference](https://developer.vonage.com/en/voice/voice-api/code-snippets/controlling-conference-calls/connect-callers-into-a-conference)
- [NCCO reference: `conversation`](https://developer.vonage.com/en/voice/voice-api/ncco-reference#conversation)
  covers moderated conferences, hold music and recording
- [Open a tunnel with the Vonage CLI](https://developer.vonage.com/en/vonage-cli/guides/tunnel/open-tunnel)

## License

This project is licensed under the [MIT License](LICENSE). Copyright 2026 Vonage.
