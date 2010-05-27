From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH] ns: Syscalls for better namespace sharing
	control.
Date: Thu, 27 May 2010 14:44:40 +0200
Message-ID: <4BFE6938.50607@free.fr>
References: <1263568754.23480.142.camel@bigi>	<m13a0tf17t.fsf@fess.ebiederm.org>
	<1266875729.3673.12.camel@bigi>	<m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi>	<m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi>	<m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi>	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<20100527122800.GC31480@nibiru.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100527122800.GC31480-q9I3ByPDOfiE+EvaaNYduQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: weigelt-EU+a56NjgY8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/27/2010 02:28 PM, Enrico Weigelt wrote:
> * Eric W. Biederman<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>  wrote:
>
> Hi,
>
>    
>> The nsfd() system call returns a file descriptor that can
>> be used to talk about a specific namespace, and to keep
>> the specified namespace alive.
>>      
> Why not directly mapping it into the filesystem (eg. /proc)
> instead of yet another syscall ?
>    

I think it is already done, the last version maps 
/proc/<pid>/ns/[net,pid,...].
You have to open one of these files and use the 'setns' syscall.

Thanks
   -- Daniel
