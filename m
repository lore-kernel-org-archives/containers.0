From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: linux-cr:  ckpt-v23-rc2 pushed
Date: Sun, 17 Apr 2011 08:13:51 -0500
Message-ID: <20110417131351.GA19709@hallyn.com>
References: <4DAA3B61.10504@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DAA3B61.10504-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Hi,
> 
> I finally merged all the recent patches and bug fixes, including hugetlb
> and pids-as-objects. I pushed it as ckpt-v23-rc2 - both linux-cr and user-cr.
> It applies on top of 2.6.37.
> 
> It passes all my testing here.

Do you have a checklist you can share?

>  I'd be happy with more testing and for more
> architectures (PPC and ARM are still out until I receive updated patchsets).
> 
> If you notice that I left out a patch/fix, please let me know.
> 
> Thanks,

I'll kick off a build hopefully tonight.

Has anyone else had some thoughts on how to start on automated testing?
Should we take a look at jenkins?  Does anyone have some hardware they
can dedicate?  I think it would be a reasonable start to do crosscompile
builds for each support arch, with and without CR, and to fire off
qemu VMs for each arch just for a standard set of c/r tests (presumably
the ones under user-cr/tests) - and do that once per day.   If it fails,
auto-fetch a list of commits since last success.

-serge
