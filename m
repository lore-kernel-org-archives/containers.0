From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Filesystems visibility control group
Date: Fri, 8 Feb 2008 09:54:48 -0600
Message-ID: <20080208155448.GA13683@sergelap.austin.ibm.com>
References: <47AB1E14.1080203@openvz.org>
	<1202404169.9065.21.camel@nimitz.home.sr71.net>
	<47AC0F2B.3070903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47AC0F2B.3070903-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> Dave Hansen wrote:
> > On Thu, 2008-02-07 at 18:04 +0300, Pavel Emelyanov wrote:
> >> Having this proxy is the easiest way to keep the global list and
> >> file_system_type structure (almost) untouched and simplify the code.
> >>
> >> The filesystems.list file syntax is simple: [+-]<name> without
> >> a '\n' at the end. Made for 2.6.24-rc8-mm1
> > 
> > For what would you want this?  What kinds of filesystems would you like
> > to restrict the use of in a container?
> 
> Any you want to.
> 
> E.g. ext3 with its journaling thread. Having 100 containers
> with a journal in each kills the node. 
> E.g. cgroupsfs if you don't want your cgroup create its 
> own ones. 

Ah, so that answers that question - you enforce this by umounting
/cgroups in the container and not letting them remount it?

> E.g. NFS that can stuck on umount and block you container
> on stop.
> 
> > -- Dave
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
