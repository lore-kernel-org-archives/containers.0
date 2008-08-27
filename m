From: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Wed, 27 Aug 2008 09:19:13 -0700
Message-ID: <48B57E81.2020708__16300.9420423352$1219854621$gmane$org@goop.org>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0808202304490.17436@takamine.ncl.cs.columbia.edu>	
	<1219437422.20559.146.camel@nimitz>
	<48B0F449.2000006@cs.columbia.edu>	
	<1219768406.8680.17.camel@nimitz>
	<48B49C61.1040003@cs.columbia.edu>	
	<1219851696.8680.67.camel@nimitz>	
	<20080827155725.GD14473@hawkmoon.kerlabs.com>
	<1219853520.8680.69.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219853520.8680.69.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Wed, 2008-08-27 at 17:57 +0200, Louis Rilling wrote:
>   
>> On Wed, Aug 27, 2008 at 08:41:36AM -0700, Dave Hansen wrote:
>>     
>>> Dang.  What's the thing we return from system calls that are
>>> unsupported?  Did I just dream that up?
>>>       
>> ENOSYS?
>>     
>
> Brain not functioning, yet.  Thanks.
>   

Or EOPNOTSUPP - but that's documented as a network error ("Operation not
supported on transport endpoint").

    J
