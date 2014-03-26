From: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux 3.14-rc8 (LXC broken)
Date: Tue, 25 Mar 2014 23:02:20 -0400
Message-ID: <1395802940.16116.16.camel@localhost>
References: <CA+55aFzFj_XMNha5gcDHfmLE_Jb-O2OpdTbZyQdarJnip1gSBQ@mail.gmail.com>
	<5331E8CB.3060708@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5331E8CB.3060708-59NiGsLHOdY@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andre Tomt <andre-59NiGsLHOdY@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2014-03-25 at 21:36 +0100, Andre Tomt wrote:
> *testing hat on*
> 
> PAM within namespaces (say, LXC) does not work anymore with 3.14-rc8,
> making login, ssh etc fail in containers unless you boot with audit=0.
> 
> This is due to a change in return value to user space; and is
> appearantly a known issue as evident in this earlier post from february:
> https://www.redhat.com/archives/linux-audit/2014-February/msg00087.html
> 
> Judging from the post it seems they want to ship 3.14 with this IMO
> quite serious regression? What is the namespace/container folks take on
> this?

Fair question.

Pam only worked in non-initial pid (or user) namespace if it was also in
the non-initial network namespace.  We added support for the network
namespace in 3.14.  So now PAM in the non-initial network namespace
functions the same as it would in the inital network namespace.  aka, it
fails.  This is actually what the audit userspace people think is the
right thing to happen.  You configured PAM to fail if it couldn't do the
right audit things, and it's failing.  Needing audit=0 is not new.

BUT given we broke (already broken [remember you configured PAM to fail
if audit didn't go well and it let you log in anyway?  aka broken?])
functionality adding network namespace support I'll send a request to
Linus tomorrow to rip out our network namespace support and I'll re-add
in 3.15 when we add pid (and partial user) namespace support.

-Eric
