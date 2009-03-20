From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Fri, 20 Mar 2009 16:48:28 -0400
Message-ID: <49C4011C.1050707@cs.columbia.edu>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>	
	<49C2C686.2060806@cs.columbia.edu>
	<871vstdtn1.fsf@caffeine.danplanet.com>	
	<49C2CDFA.4010907@cs.columbia.edu>
	<49C2D183.8040905@cs.columbia.edu>	
	<20090320181043.GB8380@us.ibm.com>
	<49C3EFAF.9030706@cs.columbia.edu>
	<1237579196.8286.239.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237579196.8286.239.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Fri, 2009-03-20 at 15:34 -0400, Oren Laadan wrote:
>> 3) In checkpoint, for each task we'll do:
>>         if (nsproxy seen first time) {
>>                 alloc nsproxy_objref
>>                 for each ns in nsproxy {
>>                         if (ns seen first time) {
>>                                 alloc ns_objref
>>                                 save state of ns
>>                         } else {
>>                                 save existing ns_objref
>>                         }
>>                 }
>>         } else {
>>                 save existing nsproxy_objref
>>         }
> 
> The problem with this is that the nsproxy is in no way, shape, or form
> exposed to userspace.  It is wholly an internal implementation detail.
> 
> Take out all the nsproxy bits you have above, and do this for each task:
> 
>>                for each ns in nsproxy {
>>                         if (ns seen first time) {
>>                                 alloc ns_objref
>>                                 save state of ns
>>                         } else {
>>                                 save existing ns_objref
>>                         }
>>                 }
> 
> And it will still _function_ *exactly* the same.  It won't be quite as
> cache or space compact, but that's fine.
> 
> If you're worried about this extra space or cache impact, it can be
> fixed up at restart with:
> 
> 	if (nsproxy_equal(tsk->nsproxy, parent->nsproxy)) {
> 		get_nsproxy(parent->nsproxy);
> 		put_nsproxy(tsk->nsproxy);
> 		tsk->nsproxy = parent->nsproxy;
> 	}
> 
> Voila.  It won't be perfect.  If the parent doesn't work we could also
> try the siblings.  

Yup.

Does that scale well with many (1000's) of tasks ?

(The motivation to expose 'nsproxy_objref' to user space was to allow
user-space to decide on a sequence of clones/unshared that will create
an equivalent process tree with space-efficient nsproxy's).

Perhaps instead of nsproxy_equal() we could use an 'nsproxy_objref'
to know a-priori that it is common, and save the "compare-and-swap"
phase altogether.

Oren.
