From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc : linux containers tool 0.6.0 release
Date: Mon, 23 Mar 2009 16:45:03 +0800
Message-ID: <d95d44a20903230145m441abd8fga4bba277ba783e42@mail.gmail.com>
References: <499EC673.8020808@fr.ibm.com>
	<d95d44a20903230048ke520376gd7701de00ff4e72d@mail.gmail.com>
	<20090323081810.GB2231@hack>
	<d95d44a20903230134j5d527b3cn3e7497069c128856@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d95d44a20903230134j5d527b3cn3e7497069c128856-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

but I met comilation error when run "make" in lxc-0.6.0.

It seems lose the libcap-devel.

And, I installed the libcap-devel-2.16.rpm and retried again, but
nothing help.

Any help?


On Mon, Mar 23, 2009 at 4:34 PM, anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> got it, thanks
>
>> Even if you don't have it in your repository, you could also try
>> to compile it by yourself, try:
>>
>> http://ftp.kernel.org/pub/linux/libs/security/linux-privs/kernel-2.6/
>>
>> --
>> Do what you love, f**k the rest! F**k the regulations!
>>
>>
>
