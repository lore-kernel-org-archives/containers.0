From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: How do containers tie to multiple IP's on a NIC?
Date: Mon, 05 Jul 2010 23:13:34 +0200
Message-ID: <4C324AFE.8000801@free.fr>
References: <20100704034023.GA29753@transpect.com>
	<4C30BC16.9090802@free.fr>	<20100704191841.GA31425@transpect.com>
	<4C30E5CB.1080902@free.fr>	<20100704230827.GA1066@transpect.com>
	<4C31AAEE.5010201@gmail.com> <20100705140750.GA3113@transpect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100705140750.GA3113-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
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

On 07/05/2010 04:07 PM, Whit Blauvelt wrote:
> On Mon, Jul 05, 2010 at 05:50:38PM +0800, Pavel Labushev wrote:
>
>    
>> What exactly are you trying to achieve? A transparent packet forwarding
>> between containers and external networks?
>>      
> I'm trying to get the overview of what can be achieved, and how. Unless I've
> missed it, there's not much documentation on even moderately complex use of
> containers. Since the capabilities are rapidly advancing, maybe I'm just
> asking the question a few months too early? From the outside, as someone new
> to containers, it looks like a maze where there are a number of entrances,
> each of which may lead approximately to the goal, but some of which may be
> dead ends.
>    
Hi Whit,

may be this documents can help you:

http://lxc.sourceforge.net/doc/sigops/appcr.pdf
