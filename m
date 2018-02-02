From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: RFC(V3): Audit Kernel Container IDs
Date: Fri, 2 Feb 2018 18:24:47 -0500
Message-ID: <CAHC9VhTg0ocArSek03A-XrbjgR4iGeysxXWaA8HknKBD_5ZRkA__26447.853833861$1517613790$gmane$org@mail.gmail.com>
References: <20180109121620.wi7dq2423ugsraqv@madcap2.tricolour.ca>
	<1515514736.3239.10.camel@redhat.com>
	<20180110070011.l4rcdcwb27witfem@madcap2.tricolour.ca>
	<CAHC9VhQ=hX55e7ftkVQCogTZTcdSm3rm-+YNOgWomabbXV_sKg@mail.gmail.com>
	<1517609946.13097.161.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1517609946.13097.161.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Feb 2, 2018 at 5:19 PM, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, 2018-02-02 at 16:24 -0500, Paul Moore wrote:
>> On Wed, Jan 10, 2018 at 2:00 AM, Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> > On 2018-01-09 11:18, Simo Sorce wrote:
>> > > On Tue, 2018-01-09 at 07:16 -0500, Richard Guy Briggs wrote:

...

>> > Paul, can you justify this somewhat larger inconvenience for some
>> > relatively minor convenience on our part?
>>
>> Done in direct response to Simo.
>
> Sorry but your response sounds more like waving away then addressing
> them, the excuse being: we can't please everyone, so we are going to
> please no one.

I obviously disagree with the take on my comments but you're free to
your opinion.

I believe saying we are pleasing no one isn't really fair now is it?
Is there any type of audit container ID now?  How would you go about
associating audit events with containers now? (spoiler alert: it ain't
pretty, and there are gaps I don't believe you can cover)  This
proposal provides a mechanism to do this in a way that isn't tied to
any one particular concept of a container and is manageable inside the
kernel.

If you have a need to track audit events for containers, I find it
extremely hard to believe that you are not at least partially pleased
by the solutions presented here.  It may not be everything on your
wishlist, but when did you ever get *everything* on your wishlist?

>> But to be clear Richard, we've talked about this a few times, it's not
>> a "minor convenience" on our part, it's a pretty big convenience once
>> we starting having to route audit events and make decisions based on
>> the audit container ID information.  Audit performance is less than
>> awesome now, I'm working hard to not make it worse.
>
> Sounds like a security vs performance trade off to me.

Welcome to software development.  It's generally a pretty terrible
hobby and/or occupation, but we make up for it with long hours and
endless frustration.

>> > u64 vs u128 is easy for us to
>> > accomodate in terms of scalar comparisons.  It doubles the information
>> > in every container id field we print in audit records.
>>
>> ... and slows down audit container ID checks.
>
> Are you saying a cmp on a u128 is slower than a comparison on a u64 and
> this is something that will be noticeable ?

Do you have a 128 bit system?  I don't.  I've got a bunch of 64 bit
systems, and a couple of 32 bit systems too.  People that use audit
have a tendency to really hammer on it, to the point that we get
performance complaints on a not infrequent basis.  I don't know the
exact number of times we are going to need to check the audit
container ID, but it's reasonable to think that we'll expose it as a
filter-able field which adds a few checks, we'll use it for record
routing so that's a few more, and if we're running multiple audit
daemons we will probably want to include LSM checks which could result
in a few more audit container ID checks.  If it was one comparison I
wouldn't be too worried about it, but the point I'm trying to make is
that we don't know what the implementation is going to look like yet
and I suspect this ID is going to be leveraged in several places in
the audit subsystem and I would much rather start small to save
headaches later.

We can always expand the ID to a larger integer at a later date, but
we can't make it smaller.

>> > A c36 is a bigger step.
>>
>> Yeah, we're not doing that, no way.
>
> Ok, I can see your point though I do not agree with it.
>
> I can see why you do not want to have arbitrary length strings, but a
> u128 sounded like a reasonable compromise to me as it has enough room
> to be able to have unique cluster-wide IDs which a u64 definitely makes
> a lot harder to provide w/o tight coordination.

I originally wanted it to be a 32-bit integer, but Richard managed to
talk me into 64-bits, that was my compromise :)

As I said earlier, if you are doing container auditing you're going to
need coordination with the orchestrator, regardless of the audit
container ID size.

-- 
paul moore
www.paul-moore.com
