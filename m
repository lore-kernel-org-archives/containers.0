From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [Fwd: Re: [PATCH] iproute2: add support for IFLA_NET_NS_PID in ip
	link v2]
Date: Mon, 23 Jun 2008 18:08:43 +0200
Message-ID: <485FCA8B.90808@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

FYI.

Thanks.
	-- Daniel


-------- Original Message --------
Subject: Re: [PATCH] iproute2: add support for IFLA_NET_NS_PID in ip link v2
Date: Mon, 23 Jun 2008 09:02:12 -0700
From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Organization: Linux Foundation
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
CC: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 
      "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
References: <20080620090734.144305411-4vkkeT0zb4ZEtYaxpPmRp1aPQRlvutdw@public.gmane.org> 
<20080620092109.551812772-4vkkeT0zb4ZEtYaxpPmRp1aPQRlvutdw@public.gmane.org> <485F59ED.2080404-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

On Mon, 23 Jun 2008 10:08:13 +0200
Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:

> Benjamin Thery wrote:
> > Ah, ah, of course I forgot to refresh the patch before sending it. :)
> > There was still a small typo in the patch: a '}' was put instead of 
> > a '|' in 'ip link' usage string. 
> > 
> > Here is the updated patch.
> > Sorry for this.
> > 
> > Benjamin
> > 
> > Description:
> > ------------
> > 
> > This patch adds support for the IFLA_NET_NS_PID type. It is used to 
> > move network devices between network namespaces.
> > 
> > The syntax is: 
> > ip link set DEVICE netns PID
> > 
> > PID is the pid of a process in the target network namespace.
> > 
> > (Daniel Lezcano is the original author). 
> > 
> > Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
> 
> Hi Stephen,
> 
> we posted this patch several times and we had no response.
> I suppose you are very busy and you had no time to answer.
> Can you briefly tell us what do you plan to do with this patch ?
> 
> 
> Thanks
>    -- Daniel
> 
I am doing a new release. It is in the list of things to go in.
But was holding off until other issues resolved. It will go in today.
