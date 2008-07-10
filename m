From: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [RFC PATCH 0/5] Resend -v2 - Use procfs to change a syscall
	behavior
Date: Thu, 10 Jul 2008 11:54:07 +0200
Message-ID: <4875DC3F.6090002@bull.net>
References: <20080708112422.164370000@bull.net>
	<m1lk0aefs1.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1lk0aefs1.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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
>>This patchset is a part of an effort to change some syscalls behavior for
>>checkpoint restart.
> 
> 
> Thanks for doing this.
> 
> Unfortunately this makes a very good case of why we don't want to go down
> this route.  Adding magic parameters to syscalls that are only useful
> in one very specific restart case.
> 
> We need good clean interfaces with well defined semantics.
> 
> Something as narrow focused on this is not really useful and it takes
> a lot of code to do something very few people will want to actively
> do.

All this seems reasonable.
Ok, so since we are taking the "new syscalls" direction, I'll try to 
make a list of the potentially duplicated syscalls.

Regards,
Nadia

> 
> 
>>The syntax is:
>># echo "LONG1 XX" > /proc/self/task/<my_tid>/next_syscall_data
>>     next object to be created will have an id set to XX
> 
> 
> Which his horrible in another way because it is hugely race prone.
> 
> Eric
> 
> 
> 
