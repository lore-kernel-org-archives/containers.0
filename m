From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/4] cgroups: show correct file mode
Date: Mon, 2 Mar 2009 16:23:46 -0800
Message-ID: <6599ad830903021623q1666c519h5f68da7203b0f58a__49827.1485594616$1236040156$gmane$org@mail.gmail.com>
References: <49AB40BF.4030706@cn.fujitsu.com>
	<6599ad830903021019p3b29c173oc7772af6679d90e0@mail.gmail.com>
	<20090303090950.60cea53a.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830903021615j6e1380e2l1544b67b187c1f5e@mail.gmail.com>
	<20090303092021.93e69b96.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090303092021.93e69b96.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 2, 2009 at 4:20 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>>
>> int mode;
>> if (cft->mode) {
>>   mode = cft->mode;
>> } else {
>>   if (cft->write_xxx || ....)
>>     mode |= 0600;
>>   if (cft->read_xxx || ...)
>>     mode |= 0444;
>> }
>>
> Oh, I see. But int mode=0, at first ;)

Oops, yes.

> I have no objections but please forgive subsys to set mode=0644 explicitly.

Do you mean "allow" rather than "forgive"? if so, then yes, a
subsystem should be able to override this to whatever it wants.

Paul
