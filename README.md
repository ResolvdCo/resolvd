# Resolvd

[Resolvd](https://resolvd.co) is customer support and help desk tool built to let you focus on supporting your customer, without overwhelming you with useless features, slow systems, and complicated pricing. 


## Why Resolvd?
* **Unlimited Conversations** - Search, store, and manage all of your customer conversations in one place, and collaborate with your team on helping them be successful.
* **Mailboxes** - Dedicated mailboxes allow you to organize your customer conversations into groups which can have their own various customization and responsibilities. 
* **White-labeled Knowledge Base** - A blazing fast, customizable, and SEO-friendly knowledge base will help your customers help themselves, all while integrating directly with your responses.
* **Privacy Focused** - Don't collect more data from your customers than you have to. Resolvd is GDPR complaint and helps you provide the same to your customers out of the box.
* **Customer Rolodex** - Keep track of your customers, where they work, and what their reporting chain is without all the complexity and cost of a CRM. 
* **Out of the Box Reporting** - No need to guess at what's important, we have reports for businesses of all sizes. Report on customer response metrics, generate reports for your board, or just get a glance of your customer happiness all in one place.
* **Real Time Collaboration** - Avoid stepping on each others feet by knowing in real time who's responding to a conversation and get real time alerts of new conversations directly in your browser.

## Development Installation

These instructions serve as a reference for getting Resolvd running whatever type of local machine you have for development. Some instructions may be specific to various distributions, substitution may be required with the correct procedure for your configuration. Production configurations will vary.

### General Dependencies

You will need the following tools to clone, build, and run Resolvd:

- **git**: Source control
- **erlang**: Runtime
- **elixir**: Language and tooling
- **postgresql**: Database
- **inotify-tools**: Filesystem monitoring dependencies for developer convenience (watching changes)


You may need to translate these exact dependencies into their appropriate names for your OS distribution.

### Setup

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Set `RESOLVD_SSL_KEY_PATH` and `RESOLVD_SSL_CERT_PATH` environment variables.
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) or [`localhost:443`](https://localhost) from your browser.

### Contributing
1. [Fork it!](http://github.com/ResolvdCo/resolvd/fork)
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request

## Help
If you need help with anything, please feel free to open [a GitHub Issue](https://github.com/ResolvdCo/resolvd/issues/new).

## Security Policy
Our security policy can be found in [SECURITY.md](SECURITY.md).

## License
Resolvd is licensed under the [GNU Affero General Public License](LICENSE.md).