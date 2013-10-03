From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Device Namespaces
Date: Wed, 02 Oct 2013 17:44:02 -0700
Message-ID: <87a9iri3ot.fsf@xmission.com>
References: <CAA2m6veny-7_ONMA973Wu36U4kz4gAuw0dpodkb8+GZDv6VNBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAA2m6veny-7_ONMA973Wu36U4kz4gAuw0dpodkb8+GZDv6VNBQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Amir Goldstein's message of "Sun, 29 Sep 2013 22:28:55 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Amir Goldstein <amir-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org> writes:

> What we really like to see is a setns() style API that can be used to
> add a device in the context of a namespace in either a "shared" or
> "private" mode.

I think you mean an "ip link set dev FOO netns XXX" style API.

Right now one of the best suggestions on the table is:

mkdir -p /dev/container/X
ln /dev/zero /dev/container/X/zero
ln /dev/null /dev/container/X/null
...

With /dev/container/X mounted on /dev for container X.

Which seems to cover putting a device in a namespace, while allowing
things to still be reasonably managed.

There are a few other variations on that scheme but nothing that says we
must have kernel support or to create any kind of kernel context beyond
which directory the device nodes live in.

> This kind of API is a required building block for us to write device
> drivers that are namespace aware in a way that userspace will have
> enough flexibility for dynamic configuration.
>
> We are trying to come up with a proposal for that sort of API.  When
> we have something decent, we shall post it.

I really think what you need to write are special drivers that
facilitate your use case.

For the networking stack we wound up adding veth pairs, and macvlan
devices, to handle the common sharing modes.

Outside of your sharing situation I am not seeing any need or any
advantage of creating devices that are modified to be sharable and I am
seeing a lot of disadvantages to implementing things that way.  The
biggest is that you seem to working independent of the subsystem
maintainers of those devices which is generally a poor idea.

Unprivileged creation of device nodes we can handle if it can be shown
that it is safe to create device nodes.

As I understand your problem you are trying to multiplex a device by
building a device with a built in stop light.  Where one opener can
write and the other openers are stopped/dropped.  That sounds very
similar to macvlan, or ethernet bridging.   From the patches you have
floated I suspect it would be very simple to build and just need a
little bit of glue.

Eric
