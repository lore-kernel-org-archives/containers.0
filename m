From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] fuse: Ensure posix acls are translated outside of
	init_user_ns
Date: Tue, 29 May 2018 09:02:03 -0500
Message-ID: <87zi0io90k.fsf__48988.3011709482$1527602438$gmane$org@xmission.com>
References: <87r2mre5b3.fsf@xmission.com> <87wovubbdf.fsf@xmission.com>
	<877enmskec.fsf@xmission.com>
	<CAOssrKdS9gOsZrNfqJbk_j0Z8-hrqrYWW+=_Z5mUEX1KE-Kw6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKdS9gOsZrNfqJbk_j0Z8-hrqrYWW+=_Z5mUEX1KE-Kw6Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Tue, 29 May 2018 14:55:25 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Tue, May 29, 2018 at 2:42 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
>>
>>> ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:
>>>
>>>> Ensure the translation happens by failing to read or write
>>>> posix acls when the filesystem has not indicated it supports
>>>> posix acls.
>>>>
>>>> This ensures that modern cached posix acl support is available
>>>> and used when dealing with posix acls.  This is important
>>>> because only that path has the code to convernt the uids and
>>>> gids in posix acls into the user namespace of a fuse filesystem.
>>>>
>>>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>>> ---
>>>
>>> ping.
>>>
>>> Miklos are you around where you can look at this?
>>
>> Perhaps I got the wrong email address.
>
>
> No, sorry.  I'll queue this up for 4.18.
>
> Just wanted to finish off overlayfs stuff before getting into fuse.

After reading your overlayfs pull it looks like those were some tricky
issues you were dealing with so it makes complete sense.

Then I am going to send you the enablement patch as I think the initial
round of work is done and you can apply them when you are ready.

Eric
