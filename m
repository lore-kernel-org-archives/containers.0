From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] make cr depend on all namespaces
Date: Mon, 15 Mar 2010 17:23:54 -0500
Message-ID: <20100315222354.GA5938@hallyn.com>
References: <20100315200559.GA25911@us.ibm.com>
	<4B9EAA5D.1080802@cs.columbia.edu>
	<20100315215244.GA5791@hallyn.com>
	<4B9EB02C.8000204@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B9EB02C.8000204-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> >Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>
> >>Serge E. Hallyn wrote:
> >>>This should let us get rid of some ifdefed code and reduce
> >>>chances for bad config combinations.  There's really no reason
> >>>to support it.
> >>I disagree.
> >>
> >>You are right that this will reduce the changes of bad config
> >>combinations.
> >>
> >>However, it will also introduce some restrictions on the kernel
> >>config which are unnecessary. Some people may not want to have
> >>all namespaces configured.
> >
> >Why?  The only reason right now to disable namespaces is for
> >kernel size.
> 
> Yup.
> 
> So we know it works well when all ns are enabled. If there are
> so few users that disable some ns, then we will rarely hear about
> breakage anyway.
> 
> On the other hand - what about current distributions - do they
> enable all namespaces by default ?  If not (mine didn't), then
> potential tester will haev yet another barrier to testing since,
> for instance, net-ns is disabled.
> 
> >
> >>Note that the namespaces are independent in the sense that we
> >>don't need to test all combination of all namespaces - instead,
> >>I consider turning on/off one at a time to be safe enough.
> >
> >And do you do that?  :)  It still gets more complicated bc
> >you have things like sysvipc and posix mq which both can allow
> >ipc_ns.
> 
> You are 100% correct - we don't, and we should automate it.
> 
> I thought you intentionally leave out IPC in that patch...  ?
> 
> Anyway, ipc is the exception, because it can be disabled as a
> whole. Can you do that on others ? (e.g. uts, user, etc)
> 
> >
> >>(FWIW, is it because you only wanted to show a point that you
> >>only remove UTS_NS ifdefs ?)
> >
> >It was just right there in my face...
> >
> >Anyway if you don't take this patch then the UTS_NS code I
> >removed should have 'name' put under ifdef to avoid a build
> >warning.
> 
> Ok, will patch away and push to v20-rc2.

Thanks, I will fetch in a bit and re-test with your (presumably
rebased) tree and report over irc.
