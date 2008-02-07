From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH 3/4]: Enable multiple mounts of /dev/pts
Date: Thu, 07 Feb 2008 13:50:46 +0300
Message-ID: <47AAE286.8080806@openvz.org>
References: <20080206050428.GA19461@us.ibm.com>	<20080206051055.GC19764@us.ibm.com>
	<47A9D8D4.6030404@openvz.org>	<20080206161608.GA16278@sergelap.austin.ibm.com>	<47A9DF31.2040302@openvz.org>	<20080206164328.GA16726@sergelap.austin.ibm.com>	<47A9E6C5.7030209@openvz.org>
	<20080206173211.GA17655@sergelap.austin.ibm.com>
	<47AADC85.1080206@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47AADC85.1080206-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
>>> Off-topic: does any of you know whether Andrew is willing to accept
>>> new features in the nearest future? The problem is that I have a 
>>> device visibility controller fixed and pending to send, but I can't
>>> guess a good time for it :)
> 
> I have the clone64/unshare64 syscalls ready for most common arches :
> 
> 	x86, x86_64, x86_64(32), ppc64, ppc64(32), s390x, s390x(31)
> 
> do you care to review or shall I send directly to andrew ?

I think you can send them t Andrew :)

> There's a freezer patchset also that I need to resend ...
> 
> C. 
>  
>> Well even if Andrew won't take it I'd like to see it, so I'd appreciate
>> a resend.
> 
