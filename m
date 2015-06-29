From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [GIT PULL] User namespace related fixes for v4.2
Date: Mon, 29 Jun 2015 09:43:09 -0700
Message-ID: <CA+55aFysKDXr2HEwNzm3z9QOw=E4ZeWcvYQ-xLhy5_k+rGbeRg__23095.7604981542$1435596208$gmane$org@mail.gmail.com>
References: <87381eyz26.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87381eyz26.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Kenton Varda <kenton-AuYgBwuPrUQTaNkGU808tA@public.gmane.org>, Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ivan Delalande <colona-nzgTgzXrdUbQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 26, 2015 at 1:50 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Therefore this changeset marks for backporting the attribute enforcement
> that do not cause regressions in the existing userspace. Implements
> enforcement of nosuid and noexec.  Then disables that enforcement of
> nosuid and nosexec and replaces that enforcment with a big fat warning.
> Userspace should be fixed before 4.2 ships so I do not expect these
> warnings to fire.

Eric, that is *not* how this works.

If people have old user-space binaries, we do not require them to be
updated. So it doesn't matter one whit if "Userspace should be fixed
before 4.2 ships", because it is entirely irrelevant if the upstream
project stops doing something, when users want to be able to upgrade
their kernels regardless of whether they've upgraded their system
apps.

I'm going to hold off on pulling this, because I feel you don't
understand the regression rules.

I suggest we instead just always set nosuid and noexec for /proc and
/sys mounts, and make this whole thing a complete non-issue.

Instead of this crazy "let's warn about it and plan on breaking old
existing setups". That's _wrong_. It's so fundamentally wrong that I
will not pull from people who do not understand this.

The reason we have that "no regression" rule is not so that we fix up
bugs. It's because peopel should always feel safe upgrading their
kernel, and basically _know_ that kernel developers consider it
unacceptable to break user space. It should be a warm fuzzy feeling -
the feeling that we try our best, and if we ever fail because we
missed something or really believed that it can't ever matter, we'll
jump on it and we won't be making any excuses for our bugs. Because
breaking user space is a bug.

Kernel developers who don't understand "it is unacceptable to break
user space" shouldn't be kernel developers.

                 Linus
