From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: Re: [PATCH] netns: Coexist with the sysfs limitations
Date: Thu, 23 Oct 2008 10:04:41 +0200
Message-ID: <49003019.40904__45238.2999276326$1224752796$gmane$org@bull.net>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m17i80nzff.fsf@frodo.ebiederm.org>
	<20081022212124.GA9910@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022212124.GA9910-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> To make testing of the network namespace simpler allow
>> the network namespace code and the sysfs code to be
>> compiled and run at the same time.  To do this only
>> virtual devices are allowed in the additional network
>> namespaces and those virtual devices are not placed
>> in the kobject tree.
>>
>> Since virtual devices don't actually do anything interesting
>> hardware wise that needs device management there should
>> be no loss in keeping them out of the kobject tree and
>> by implication sysfs.  The gain in ease of testing
>> and code coverage should be significant.
>>
>> I.e. people running distributions that make it next to
>> impossible to boot without sysfs should at be able to
>> boot a test kernel now.
>>
>> Plus no ABIs are harmed with this patch.

>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Duh.
> 
> Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Oh, this patch is short, clean, and the limitation introduced isn't too
annoying for testing netns right now.

At least, my proposal provoked some reactions :)

BTW, there's a second limitation with your patch:
we can't rename the net devices in the additional network namespaces.

In net/core/dev.c, dev_change_name() fails: call to device_rename() 
return an (expected) -EINVAL error.
Maybe we should add a test on the net to only call it in init_net?

  rollback:
-       err = device_rename(&dev->dev, dev->name);
-       if (err) {
-               memcpy(dev->name, oldname, IFNAMSIZ);
-               return err;
+       if (net == &init_net) {
+               err = device_rename(&dev->dev, dev->name);
+               if (err) {
+                       memcpy(dev->name, oldname, IFNAMSIZ);
+                       return err;
+               }
         }

Otherwise,

Acked-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>

Thanks,
Benjamin

> 
> Thanks, Eric!  Thanks, Benjamin!
> 
> -serge
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
