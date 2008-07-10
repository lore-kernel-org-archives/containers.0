From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [RFC PATCH 5/5] use next syscall data to predefine the file
	descriptor value
Date: Thu, 10 Jul 2008 08:25:48 +0200
Message-ID: <4875AB6C.7080001@bull.net>
References: <20080708112422.164370000@bull.net>	<20080708112459.632357000@bull.net>
	<m1tzeyefz9.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1tzeyefz9.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Nadia.Derbey-6ktuUTfB/bM@public.gmane.org writes:
> 
> 
>>[PATCH 05/05]
>>
>>This patch uses the value written into the next_syscall_data proc file
>>as a target file descriptor for the next file to be opened.
>>
>>This makes it easy to restart a process with the same fds as the ones it was
>>using during the checkpoint phase, instead of 1. opening the file, 2. dup2'ing
>>the open file descriptor.
> 
> 
> As it happens the behavior of open is deterministic.  So if you open
> the files in the right order you should not need this.  dup2 is only needed
> if there is a gap in the fds used.
> 

This covers the case where you're checkpointing a process that has
1. opened, say 3 files (fds x, x+1, and x+2)
2. closed fd x+1
--> checkpoint occurs at that point.

During restart, you'll have to only recreate fds x and x+2.

But I'm realizing that this might be what you're calling a gap in the 
fds ;-)

Regards,
Nadia
