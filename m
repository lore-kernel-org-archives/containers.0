From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add a multi-process IPC test
Date: Sun, 12 Apr 2009 09:20:34 -0500
Message-ID: <20090412142034.GA6031@hallyn.com>
References: <1239299170-14827-1-git-send-email-danms@us.ibm.com>
	<20090409185159.GA32610@us.ibm.com>
	<49E12C5F.5020209@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E12C5F.5020209-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >> This test forks off several children in various states to ensure that the
> >> IPC namespace information is properly restored after restart.
> > 
> > Thanks, Dan.  I've got a few other simple c/r tests collected which I
> > want to automate in the next few days so one can just run 'check_cr' and
> > get a list of pass/fails.  I'll also add some tests which Nathan had
> > written for IPC.  Hmm, I suppose the easiest thing for now will be to
> > put a tarball on lxc.sf.net.
> 
> I include the c/r tests with the c/r userland tools (ckpt, mktree etc).
> That's a natural repository to collect/hold them.

The natural place is ltp :)  Meanwhile I wanted to automate a few tests,
but if you wanted to add those to your user-cr tree that'd be great.  I
don't actually *want* them on lxc.sf.net, just had nowhere else to put
them.

thanks,
-serge
