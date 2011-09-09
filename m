From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/15] user ns: setns: move capable checks into per-ns
	attach helper
Date: Fri, 9 Sep 2011 14:56:36 +0000
Message-ID: <20110909145636.GA24954__25849.9870113612$1315580200$gmane$org@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
	<1314993400-6910-5-git-send-email-serge@hallyn.com>
	<20110904015140.GB32295@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110904015140.GB32295-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Fri, Sep 02, 2011 at 07:56:27PM +0000, Serge Hallyn wrote:
> > From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> 
> I was confused about this patch until I realized that you're not
> simply "moving" the capability checks but "distributing" them. Then
> you're showing that you'll soon change some to nsown_capable() or
> ns_capable() using the strange cpp pattern in the snippet below.
> 
> At least I think that's what you intended. A commit message would
> help :).

Yes, sorry - Eric convinced me several times to be more conservative in
the patch, and I failed to fix the commit msg when squashing the
resulting patches.  How about the following:

======

user ns: update capable calls when cloning and attaching namespaces

Distribute the capable() checks at ns attach into the namespace-specific
attach handler.

Note the fact that the capable() checks will be changed to targeted
checks at both namespace clone and attach methods, but don't actually
make that change yet.  Until that trigger is pulled, you must have
the capabilities targeted toward the initial user namespace in order to
do any of these actions, meaning that a task in a child user namespace
cannot do them.  Once we pull the trigger, a task in a child user
namespace will be able to clone new namespaces if it is privileged in
its own user namespace, and attach to existing namespaces to which it
has privilege.

======

Thanks for taking a look, Matt!

-serge
