From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: User namespaces and keys
Date: Wed, 23 Feb 2011 13:37:16 -0800
Message-ID: <4D657E0C.3010102__21785.0180728876$1298497246$gmane$org@schaufler-ca.com>
References: <20110223135814.GA1859@mail.hallyn.com>	<20110217150224.GA26334@mail.hallyn.com>
	<29677.1298462729@redhat.com>	<890.1298473574@redhat.com>
	<m162sasqj6.fsf@fess.ebiederm.org>	<20110223155328.GA21266@peq.hallyn.com>	<4D655EE4.6030707@schaufler-ca.com>
	<m1k4gqlbdm.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1k4gqlbdm.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2/23/2011 12:55 PM, Eric W. Biederman wrote:
> Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org> writes:
>
>> I confess that I remain less well educated on namespaces than
>> I probably should be, but with what I do know it seems that the
>> relationships between user namespaces and LSMs are bound to be
>> strained from the beginning. Some LSMs (SELinux and Smack) are
>> providing similar sandbox capabilities to what you get from user
>> namespaces, but from different directions and with different
>> use cases.
> Casey I won't argue about the possibility of things being strained, but
> I think if we focus on the semantics and not on the end goal of exactly
> how the pieces are to be used there can be some reasonable dialog.

I'm sure that there will be cases where they will work together
like horses in a troika. Making sensible semantics for the interactions
is key, and it is entirely possible that in some cases a comparison
of semantics and behaviors will lead an end user to chose either an
LSM or namespaces over the combination. Just like I expect that even
when we allow multiple LSMs the SELinux and Smack combination will be
rare among the sane.
