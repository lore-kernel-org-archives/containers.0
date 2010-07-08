From: Daniel Lezcano <daniel.lezcno-GANU6spQydw@public.gmane.org>
Subject: Re: LXC on ARM (RISC)
Date: Fri, 09 Jul 2010 00:06:46 +0200
Message-ID: <4C364BF6.4010309@free.fr>
References: <20100708225405.7a089095@packard.rktmb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100708225405.7a089095-jVktQDY1Ej77k9Ui2d6hDdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mihamina Rakotomandimby <mihamina-NTEeVpikYLd60m5Y2ZoSiQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/08/2010 09:54 PM, Mihamina Rakotomandimby wrote:
> Manao ahoana, Hello, Bonjour,
>
> Will LXC work in this ARM (RISC) CPU?
> http://www.tilera.com/products/TILEPro64.php
>
> Misaotra, Thanks, Merci.
>    

LXC is not arch-dependant. It should work if the network driver on your 
system is compatible with the network virtualization.
