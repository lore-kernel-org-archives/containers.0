From: Nikolay Borisov <n.borisov.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] inotify: Convert to using per-namespace limits
Date: Thu, 8 Dec 2016 08:58:31 +0200
Message-ID: <e86b3a4f-51d5-ea61-93f3-883fe2dbcf34@gmail.com>
References: <20161010164046.GG24081@quack2.suse.cz>
	<1476171382-11911-1-git-send-email-kernel@kyup.com>
	<674564a4-ff05-b4d6-4a98-8cfc2e609325@kyup.com>
	<87twafci52.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87twafci52.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org



On  8.12.2016 03:40, Eric W. Biederman wrote:
> Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:
> 
>> Gentle ping, now that rc1 has shipped and Jan's sysctl concern hopefully
>> resolved.
> 
> After getting slowed down by some fixes I am now taking a hard look at
> your patch in the hopes of merging it.
> 
> Did you happen to see the kbuild test roboot boot failures and did you
> happen to look into what caused them?  I have just skimmed them and it
> appears to be related to your patch.

I saw them in the beginning but they did look like a generic memory
corruption and I believe at the time those patches were submitted there
was a lingering memory corruption hitting various patches. Thus I didn't
think it was related to my patches. I've since left my work so been
taking a bit of time off and haven't looked really hard, so those
patches have been kind of lingering.


But now that you mention it I will try and take a second look to see
what might cause the memory corruption? Is there a way to force 0day to
re-run them to see whether the failure was indeed caused by my patches
or were intermittent?

Regards,
Nikolay


> 
> Eric
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
> 
