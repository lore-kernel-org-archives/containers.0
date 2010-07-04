From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: How do containers tie to multiple IP's on a NIC?
Date: Sun, 04 Jul 2010 18:51:34 +0200
Message-ID: <4C30BC16.9090802@free.fr>
References: <20100704034023.GA29753@transpect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100704034023.GA29753-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/04/2010 05:40 AM, Whit Blauvelt wrote:
> Hi,
>
> In the containerless world, I often have multiple IPs assigned to a NIC. The
> scant documentation I can find on running containers only ever speaks of
> single IP assignment schemes. Can I have for example a box with a single NIC
> with 8 IPs assigned to it, where the host gets one IP, or perhaps
> alternately can see all 8 to run iptables across, but each of the containers
> can see only whichever IP or IPs are assigned to it?
>    

What container userspace command are you using ? libvirt ? liblxc ? 
unshare --net ?

Thanks
   -- Daniel
