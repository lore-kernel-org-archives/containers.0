From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: unshare() pid ns
Date: Thu, 30 Aug 2007 18:34:29 +0200
Message-ID: <46D6F195.7060800@fr.ibm.com>
References: <20070830052928.GA27864@us.ibm.com> <46D67B8B.2000606@openvz.org>
	<20070830133422.GA28129@sergelap.austin.ibm.com>
	<46D6D00F.7090303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46D6D00F.7090303-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Pavel ! 

Pavel Emelyanov wrote:
> Serge E. Hallyn wrote:
>> Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
>>> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>>>> Pavel,
>>>> unshare() of pid ns seems to fail with -EINVAL in 2.6.23-rc3-mm1.
>>>> I thought we supported it in the earlier patchsets.  I guess
>>>> I missed that in the review of recent patchsets.
>>> I disabled unsharing of pid namespaces because it's almost
>>> impossible. Look - you have to reattach all the pids to the
>>> task with saving its ids as seen in previous namespaces.
>> We agree, but thought you for some perverse reason preferred unshare to
>> clone for pidns :)
> 
> I did that in my first version of patches, but then realized
> that such problem (the need in reattaching pids) makes the
> unsharing ugly.
> 
> BTW, unsharing of a pid namespace is a valid operation, so I
> think I will enable it in the nearest future. I have some
> thought on how to make such a reattach ;)

that would be also very useful to 'enter' such a namespace.

BTW, did you take a look at the sys_hijack() serge sent ? 

Thanks,

C.
