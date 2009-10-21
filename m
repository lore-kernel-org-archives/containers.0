From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: LXC PIDs, UIDs, and halt
Date: Tue, 20 Oct 2009 20:04:13 -0500
Message-ID: <68e6eac60910201804h3f243cdel5a437701bf9c00ac@mail.gmail.com>
References: <68e6eac60910110930q74358967o19e3d0e88e111bd5@mail.gmail.com>
	<20091012150355.GA5783@us.ibm.com>
	<68e6eac60910191217s5d295e54ta6b0c528dce9ce55@mail.gmail.com>
	<20091019222445.GA16774@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091019222445.GA16774-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Oct 19, 2009 at 5:24 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>> On Mon, Oct 12, 2009 at 10:03 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>> > Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
---< snip >---
>> Is there anyway to readily know the id of the PID namespace one is in?
>> keychain has some issues that I could correct if I could get at the
>> PID namespace id.
>
> No, because pid namespaces don't actually have an id.
>
> What exactly are the keychain issues?  So far the keychain/namespacing
> handling is very basic (new user-namespace = new set of keyrings), bc
> there really weren't any user requirements to draw on yet.
>
>> I guess expecting apps like keychain to be namespace aware would be
>> like expecting them to be "multiverse" aware.
>>
>> I know I can pass it in through lxc-execute via an environment
>> variable, but I wondered if there was a more standard way.
>
> Well if there is a clean and safe way to do it (whatever 'it' is) through
> environment variable all the better, then we can avoid kernel changes.
> But if you need kernel help pls let us know.
>
> -serge
>

Ok, the issue is that what is stored in the file that keychain
produces is based on PID
When logging into a different PID namespace that file is considered
stale, because there is not an agent at that pid, so the file is
overwritten by keychain.

I'd to modify the filename to have the current namespace name (passed
in via environment variable) be part of it, so that the proper one is
checked by keychain and sourced by my shell

It would require a keychain change either way, whether I'd use an
environment variable or something was done to the kernel to allow it
to be retrieved.

A lot of applications that base things off a PID stored in a file will
have issues when multiple PID namespaces are in play, and where those
files are in the same locations in each container.

I'm not asking for any kernel help, an environment variable will suffice.

I'll patch keychain, and once I've determined it works correctly, I'll
see if the maintainers (The Funtoo folk) will accept the patch.

-- Dwight
