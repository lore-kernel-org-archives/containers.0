From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Fri, 20 Mar 2009 13:10:43 -0500
Message-ID: <20090320181043.GB8380@us.ibm.com>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
	<49C2C686.2060806@cs.columbia.edu>
	<871vstdtn1.fsf@caffeine.danplanet.com>
	<49C2CDFA.4010907@cs.columbia.edu>
	<49C2D183.8040905@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49C2D183.8040905-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> What got me confused was that you loop over all tasks, which is not
> needed because was assume they all share the name nsproxy; And in
> restart, you unshare() many times by the same task, so all but the
> last unshare() are useless.  In other words, I wonder what is the
> need for that loop over all processes.
> 
> Here is a suggestion for a simple change that is likely to be a step
> towards more generic solution in the future:
> 
> The nsprox is a property of a task, and it is (possibly) shared. We
> can put the data either on the pids_arr or on the cr_hdr_task itself.
> For simplicity (and to work with your scheme) let's assume the former.
> 
> We can extend the pids_arr to have a ns_objref field, that will hold
> the objref of the nxproxy. Of course, now, all pids_arr will have the
> same objref, or else ...  This data will follow the pids_arr data in
> the image.
> 
> During checkpoint, we read the pids_arr from the image, and then for
> each objref of an nsproxy that is seen for the first time, we read
> the state of that nsproxy and restore a new one. (In our simple case,
> there will always be exactly one).

The nsproxy is not the right thing to record.  Rather, it
should record a bitmap  of namespaces which are to be private
from the parent task.  Then for each private ns, an optional
section with configuration info.

(maybe that is waht you meant by 'recording the nsproxy')

-serge
