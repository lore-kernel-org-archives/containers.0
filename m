From: Mihamina Rakotomandimby <mihamina-NTEeVpikYLd60m5Y2ZoSiQ@public.gmane.org>
Subject: host PCI (-X) device assigned to a container
Date: Thu, 14 Oct 2010 09:24:37 +0300
Message-ID: <20101014092437.37cf8c86@packard.rktmb.org>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Manao ahoana, Hello, Bonjour,

I would like to directly use a PCI device from a caontainer. For
example, this one:
http://www.sangoma.com/products/hardware_products/transcoding/overview.html

I saw that using libvirt I can do it
(http://libvirt.org/formatdomain.html#elementsUSB), but how to do it in
"lxc.conf"?
I suppose (not really sure) that using "lxc.cgroup.devices.allow" is a
tip, but once the PCI device plugged, how to guess the numbers &
letters to set up?


Misaotra, Thanks, Merci.


-- 

       Architecte Informatique chez Blueline/Gulfsat:
    Administration Systeme, Recherche & Developpement
                                    +261 34 56 000 19
