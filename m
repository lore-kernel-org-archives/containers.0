From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: net namespace plans for 2.6.25 (was Re: Pid namespaces problems)
Date: Thu, 08 Nov 2007 14:42:25 +0100
Message-ID: <47331241.2090501@fr.ibm.com>
References: <472AE42F.5000602@openvz.org>	<m1640id57r.fsf@ebiederm.dsl.xmission.com>	<47301A14.9040304@openvz.org>
	<4731772D.3060806@fr.ibm.com> <47317EA7.6030500@free.fr>
	<4731E3DE.6000501@openvz.org> <4731F4BC.4000203@fr.ibm.com>
	<4732EA8E.7080400@sw.ru> <47330F1F.4080806@fr.ibm.com>
	<47331122.3000304@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47331122.3000304-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Daniel Lezcano wrote:
>> Denis V. Lunev wrote:
>>> Daniel Lezcano wrote:
>>>
>>>>  * the first one is the locking of the network namespace list by
>>>> rtnl_lock, so from the timer callback we can not browse the network
>>>> namespace list to check the age of the routes. It is a problem I would
>>>> like to talk with Denis if he has time
>>> From my point of view, the situation is clear. The timer should be
>>> per/namespace. The situation is completely different as one in IPv4.
>> We thought to make a timer per namespace for ipv6, but we are a little 
>> afraid for the performances when there will be a lot of containers.
>> Anyway, we can do a timer per namespace and optimize that later. I will 
>> cook a new patch to take into account that for the next week.
> 
> I propose to start a new mailing thread for net namespaces discussions
> or at least change this one's subject ;)

done.

C.
