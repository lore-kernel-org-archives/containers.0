From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 16/29] A new file type (CR_FD_OBJREF) for
	a file descriptor already setup
Date: Wed, 01 Apr 2009 10:13:54 -0400
Message-ID: <49D376A2.9050203@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-17-git-send-email-orenl@cs.columbia.edu>
	<20090401135952.GA16973@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090401135952.GA16973-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> While file pointers are shared objects, they may share an underlying
>> object themselves. For instance, file pointers of both ends of a pipe
>> that share the same pipe inode. In this case, the shared entity to
>> handle is the inode that is shared among two file pointers (e.g read-
>> and write- ends). In this sort of "nested sharing" we need only save
>> the underlying object once (upon first encounter) on checkpoint, and
>> restore it only once during restart.
>>
>> To checkpoint a file descriptor of this sort, we first lookup the
>> inode in the hash table:
> 
> Sorry I've not followed well on irc.  What is the plan and timeline
> with respect to this and Dave's fops approach?  Is someone rewriting
> the pipes patches on top of that?  Will that replace this patch as
> well?  Who is doing it, and when will we see that patch?
> 

The fops approach is already implemented for checkpoint. I already
modified the pipe implementation accordingly.

So there are 'generic_file_checkpoint()' and 'pipe_file_checkpoint()'
both in place.

The restart is remains the same for all file types.

I think Dave is working on another change that will modify the format
of the checkpoint.

> I'm just wondering how closely to review the next 3 patches.

Please do :)

Oren.
