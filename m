From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: 2.6.35: unshare(NEWNS) does not work inside a container anymore?
Date: Wed, 01 Sep 2010 23:53:58 +0400
Message-ID: <4C7EAF56.7070909@msgid.tls.msk.ru>
References: <4C7CE137.5090009@msgid.tls.msk.ru>
	<20100901162833.GA13274@hallyn.com>
	<4C7E8D1B.2060204@msgid.tls.msk.ru>
	<20100901194136.GA13918@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100901194136.GA13918-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

01.09.2010 23:41, Serge E. Hallyn wrote:
[]
>>>> unshare(CLONE_NEWNS)              = -1 EINVAL (Invalid argument)
[]
>>> 	 ns_exec -m /bin/bash;  play with mounts; exit)
>> This one is not using unshare(2), it is using clone(2) syscall.
> 
> That's only the case if you do 'ns_exec -cm'.

Oh.  I missed that.
[]
>> The source of this clone program is available at
>> http://www.corpit.ru/mjt/clone.c - I use it for
>> a long time, it works on this same machine
>> outside of containers, and it worked in 2.6.32.
> 
> Hm, is working for me.  You're on a plain upstream 2.6.35, as in commitid
> 9fe6206f400646a2322096b56c59891d530e8d51 ?

No, it's 2.6.35.4 - last stable.  Plain 2.6.35 works (or fails)
the same for me as 2.6.35 - this one:
http://kernel.org/pub/linux/kernel/v2.6/linux-2.6.35.tar.bz2

But I see at least one possible difference: I run 64bit kernel
and a 32bit userspace, including lxc tools and unshare code.
Lemme check with 64bit (native) userspace....

/mjt
