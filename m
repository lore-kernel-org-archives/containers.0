From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 0/3][V2] remove the ns_cgroup
Date: Tue, 28 Sep 2010 15:50:17 +0200
Message-ID: <4CA1F299.3000603@free.fr>
References: <1285582453-6127-1-git-send-email-daniel.lezcano@free.fr>	<20100927125741.0df22f09.akpm@linux-foundation.org>	<20100927203658.GA5320@hallyn.com>
	<20100927134619.ecefe9f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100927134619.ecefe9f4.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/27/2010 10:46 PM, Andrew Morton wrote:
> On Mon, 27 Sep 2010 15:36:58 -0500
> "Serge E. Hallyn"<serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>  wrote:
>
>    
>>>> This patchset removes the ns_cgroup by adding a new flag to the cgroup
>>>> and the cgroupfs mount option. It enables the copy of the parent cgroup
>>>> when a child cgroup is created. We can then safely remove the ns_cgroup as
>>>> this flag brings a compatibility. We have now to manually create and add the
>>>> task to a cgroup, which is consistent with the cgroup framework.
>>>>          
>>> So this is a non-backward-compatible userspace-visible change?
>>>        
>> Yes, it is.
>>
>> Patch 1 is needed to let lxc and libvirt both control containers with
>> same cgroup setup.  Patch 3 however isn't *necessary* for that.  Daniel,
>> what do you think about holding off on patch 3?
>>      
> One way of handling this would be to merge patches 1&2 which add the
> new interface and also arrange for usage of the old interface(s) to
> emit a printk, telling people that they're using a feature which is
> scheduled for removal.
>    

Right, that makes sense.

Do you will take the patches #1 and #2, drop the patch #3, and I send a 
new patch with the printk warning ?
Or shall I resend all ?

Thanks
   -- Daniel
