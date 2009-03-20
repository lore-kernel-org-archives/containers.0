From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Fri, 20 Mar 2009 15:34:07 -0400
Message-ID: <49C3EFAF.9030706@cs.columbia.edu>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
	<49C2C686.2060806@cs.columbia.edu>
	<871vstdtn1.fsf@caffeine.danplanet.com>
	<49C2CDFA.4010907@cs.columbia.edu>
	<49C2D183.8040905@cs.columbia.edu>
	<20090320181043.GB8380@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090320181043.GB8380-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> What got me confused was that you loop over all tasks, which is not
>> needed because was assume they all share the name nsproxy; And in
>> restart, you unshare() many times by the same task, so all but the
>> last unshare() are useless.  In other words, I wonder what is the
>> need for that loop over all processes.
>>
>> Here is a suggestion for a simple change that is likely to be a step
>> towards more generic solution in the future:
>>
>> The nsprox is a property of a task, and it is (possibly) shared. We
>> can put the data either on the pids_arr or on the cr_hdr_task itself.
>> For simplicity (and to work with your scheme) let's assume the former.
>>
>> We can extend the pids_arr to have a ns_objref field, that will hold
>> the objref of the nxproxy. Of course, now, all pids_arr will have the
>> same objref, or else ...  This data will follow the pids_arr data in
>> the image.
>>
>> During checkpoint, we read the pids_arr from the image, and then for
>> each objref of an nsproxy that is seen for the first time, we read
>> the state of that nsproxy and restore a new one. (In our simple case,
>> there will always be exactly one).
> 
> The nsproxy is not the right thing to record.  Rather, it
> should record a bitmap  of namespaces which are to be private
> from the parent task.  Then for each private ns, an optional
> section with configuration info.

Rethinking, I agree that the nsproxy is not the right thing to record.
On the other hand, a bitmap is insufficient to expose the relationships
of sharing.

Putting aside the pidns for a second, I'd think that all other ns's may
be relative easy to handle, even nested. Let me try to explain:

1) An nsproxy is a shared resource, so it gets an nsproxy_objref

2) Each ns in an nsproxy is itself shared (analoguous to file and then inode,
in pipes), so each ns also gets an ns_objref.

3) In checkpoint, for each task we'll do:
	if (nsproxy seen first time) {
		alloc nsproxy_objref
		for each ns in nsproxy {
			if (ns seen first time) {
				alloc ns_objref
				save state of ns
			} else {
				save existing ns_objref
			}
		}
	} else {
		save existing nsproxy_objref
	}

4) In restart, we'll do the same, but also creating the ns's and the nsproxy's

Just as we can restore a file in one process and use the point for another
process, we could pull the same trick to assign nsproxy's to processes, and
to assign ns's to nsproxy's.

The only caveat that is left, and which is also a constraint on the process,
is the nspid - which, in a sense, is a property of the nsproxy.

If we are to restore those in user space, then the nspid will eventually
dictate, I believe, the order of forks when creating the tasks, just as the
session id may be a constraint. I do need to think it further.

Oren.

> (maybe that is waht you meant by 'recording the nsproxy')
> 
> -serge
> 
