From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Tue, 04 Nov 2008 13:33:14 -0800
Message-ID: <4910BF9A.1010300@google.com>
References: <1225219047.12673.182.camel@nimitz>	<4909FAA8.5000107@cs.columbia.edu>
	<20081030192817.GA16340@us.ibm.com>	<490A0F67.5000303@cs.columbia.edu>
	<1225397484.12673.358.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1225397484.12673.358.camel@nimitz>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Thu, 2008-10-30 at 15:47 -0400, Oren Laadan wrote:
>>   3. Your approach doesn't play well with what I call "checkpoint that
>>   involves self". This term refers to a process that checkpoints itself
>>   (and only itself), or to a process that attempts to checkpoint its own
>>   container.  In both cases, there is no other entity that will read the
>>   data from the file system while the caller is blocked.
>>
>> This is a key point for me, with multiple use cases. The simplest, if
>> you will, is for a process to simply checkpoint itself (no containers
>> and other crap :p). Same for dumping your own container. And there are
>> others.
> 
> Let's take a step back here.  I believe that strictly enforcing this
> requirement strictly requires that the checkpoint be done in its
> entirety by the kernel.
> 
> A process must have its state serialized in a repeatable way.  That
> basically precludes  it running during the checkpoint, or having its
> state change in any way that isn't atomic.
> 
> If a process can't be, itself, running during a checkpoint, then
> something running must be performing the checkpoint.  That "something"
> must either be another process or the kernel.  Since you've defined the
> goal as a self-checkpoint, it *can't* be another process.  So, it *must*
> be the kernel.

Stepping in a little late into the conversation here, but a 
self-checkpoint to me means "initiated by self".  It doesn't preclude a 
userland service (outside our container or whatever) performing the 
grunge work for us once asked.

> 
> When it comes down to it, I think this point drives quite a bit of the
> implementation.  The cr_kread/write(), for instance.  We *need* the
> kernel to do the writing since we've completely precluded userspace from
> doing it.
> 
> -- Dave
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
