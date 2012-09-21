From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 01/14] userns: Convert loop to use kuid_t instead of uid_t
Date: Fri, 21 Sep 2012 00:19:07 -0700
Message-ID: <878vc3sv10.fsf@xmission.com>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
	<505C0438.9060907@fusionio.com> <87sjabsvkx.fsf@xmission.com>
	<505C1331.8050907@fusionio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <505C1331.8050907-5c4llco8/ftWk0Htik3J/w@public.gmane.org> (Jens Axboe's message of "Fri, 21
	Sep 2012 09:11:45 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org> writes:

> On 2012-09-21 09:07, Eric W. Biederman wrote:
>> Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org> writes:
>> 
>>> On 2012-09-21 02:28, Eric W. Biederman wrote:
>>>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>>>
>>>> Cc: Signed-off-by: Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
>>>> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>>> ---
>>>>  drivers/block/loop.c |    4 ++--
>>>>  include/linux/loop.h |    2 +-
>>>>  init/Kconfig         |    1 -
>>>>  3 files changed, 3 insertions(+), 4 deletions(-)
>>>
>>> Thanks Eric, queued for 3.7.
>> 
>> Would it be a problem if I also merged throug my user-namespace.git tree?
>> 
>> That was the original plan and it is handy to keep all of the patches
>> together.
>> 
>> Not that it matters much in this case.
>
> Not at all, go ahead. It'll be trivial to resolve any merge conflict due
> to this.
>
> BTW, this:
>
> Cc: Signed-off-by: Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
>
> in your original patch needs fixing up. I'm assuming it's a copy-paste
> error and meant to be a Cc, since I haven't signed-off on it.

Doh.  Yes sorry.  It was supposed to just be Cc:

Eric
