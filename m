From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 09/11] ipc/shm: Fix shmctl(..., IPC_STAT,
	...) between pid namespaces.
Date: Wed, 28 Mar 2018 18:04:22 -0500
Message-ID: <87woxvajk9.fsf__33132.5607760393$1522278230$gmane$org@xmission.com>
References: <87vadmobdw.fsf_-_@xmission.com>
	<20180323191614.32489-9-ebiederm@xmission.com>
	<7df62190-2407-bfd4-d144-7304a8ea8ae3@oracle.com>
	<87lgeio4tb.fsf@xmission.com>
	<1091a91e-f8ee-b091-6d95-78b33520fb2d@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1091a91e-f8ee-b091-6d95-78b33520fb2d-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> (NAGARATHNAM
	MUTHUSAMY's message of "Fri, 23 Mar 2018 14:41:29 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: NAGARATHNAM MUTHUSAMY <nagarathnam.muthusamy-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: esyr-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, prakash.sangappa-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

NAGARATHNAM MUTHUSAMY <nagarathnam.muthusamy-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> writes:

> On 3/23/2018 2:33 PM, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org wrote:
>> NAGARATHNAM MUTHUSAMY <nagarathnam.muthusamy-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> Thanks!
>>>
>>> Reviewed-by: Nagarathnam Muthusamy <nagarathnam.muthusamy-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> Does this look like it will address the issue you have been fighting
>> with pids?
>
> We do use IPC shared memory but it is a single large one, shared by multiple
> levels. We are currently looking into using a similar solution based on file
> locks.
> When a new level is created, a file representing that level could be created in
> a common path which could be locked by the init process of that level.
> Parent levels could query the locking pid of that file to get the pid
> translation
> of the init process of the required level. Then it could open a file descriptor
> and use the translate_pid API for further translations.

Do you want to resend the translate_pid API with file descriptors as it
was in the lwn article?  That I will apply.

Eric
