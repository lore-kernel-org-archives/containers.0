From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: SNMP statistics in namespaces
Date: Fri, 22 Aug 2008 08:20:46 -0700
Message-ID: <1219418446.20559.60.camel@nimitz>
References: <C4D47648.E5E8%echaudron@extremenetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <C4D47648.E5E8%echaudron-SvgryPHmmKB+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eelco Chaudron <echaudron-SvgryPHmmKB+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Cc: "Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-08-22 at 13:57 +0200, Eelco Chaudron wrote:
> I was looking at the 2.6.26 nw namespace code, and noticed that the
> SNMP counters are still system wide. Looking at the status page there
> is not separate item on SNMP. Was this overlooked, skipped on purpose,
> or is it in the pipeline?
> 
> Hope some one can answer this...

I'm an idiot.  I know that SNMP has something to do with network
statistics, and I'm too lazy to google it.

Could you give us a quick idea why SNMP is important here?  You're
welcome to add it to the list, but it's unlikely to get implemented
until someone thinks it is important.  That said, I'd be happy to help
you put together some patches to implement it.

-- Dave
