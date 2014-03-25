From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux 3.14-rc8 (LXC broken)
Date: Tue, 25 Mar 2014 16:32:26 -0500
Message-ID: <20140325213226.GC14857__49397.7380254821$1395784104$gmane$org@sergelap>
References: <CA+55aFzFj_XMNha5gcDHfmLE_Jb-O2OpdTbZyQdarJnip1gSBQ@mail.gmail.com>
	<5331E8CB.3060708@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Andre Tomt (andre-59NiGsLHOdY@public.gmane.org):
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

Without looking too deeply, it seems to me that patch has no
benefit on its own, and should simply be stashed until the next
set of patches are ready.

-serge
