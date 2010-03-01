From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Mon, 1 Mar 2010 13:36:23 -0800
Message-ID: <20100301133623.9808986f.akpm__5240.10244193978$1267479517$gmane$org@linux-foundation.org>
References: <4B83106C.7040203@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B83106C.7040203-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux-Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 22 Feb 2010 18:17:00 -0500
Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

> Hi Andrew,
> 
> We've put a stake in the ground for our next set of checkpoint/restart
> patches, v19. It has some great new stuff, and we put extra effort to
> address your concerns. We would like to have the code included in -mm
> for wider feedback and testing.
> 
> This one is able to checkpoint/restart screen and vnc sessions, and
> live-migrate network servers between hosts. It also adds support for
> x86-64 (in addition to x86-32, s390x and powerpc). It is rebased to
> kernel 2.6.33-rc8.
> 
> Since one of your main concerns was about what is not yet implemented
> and how complicated or ugly it will be to support that, we've put up
> a wiki page to address that. In it there is a simple table that lists
> what is not implemented and the anticipated solution impact, and for
> some entries a link to more details.
> 
> The page is here:   http://ckpt.wiki.kernel.org/index.php/Checklist

Does "Refuses to Checkpoint" mean that an attempt to checkpoint will
fail, return the failure to userspace and the system continues as
before?

> We want to stress that the patchset is already very useful as-is. We
> will keep working to implement more features cleanly. Some features we
> are working on include network namespaces and device configurations,
> mounts and mounts namespaces, and file locks. Should a complicated
> feature prove hard to implement, users have alternatives systems like
> kvm, until we manage to come up with a clean solution.
> 
> We believe that maintenance is best addressed through testing. We now
> have a comprehensive test-suite to automatically find regressions.
> In addition, we ran LTP and the results are the same with CHECKPOINT=n
> and =y.
> 
> If desired we'll send the whole patchset to lkml, but the git trees
> can be seen at:
> 
>    kernel:       http://www.linux-cr.org/git/?p=linux-cr.git;a=summary
>    user tools:   http://www.linux-cr.org/git/?p=user-cr.git;a=summary
>    tests suite:  http://www.linux-cr.org/git/?p=tests-cr.git;a=summary
> 

I'd suggest waiting until very shortly after 2.6.34-rc1 then please
send all the patches onto the list and let's get to work.
