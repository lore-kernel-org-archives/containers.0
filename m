From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] Teach cifs about network namespaces (take 2)
Date: Wed, 12 Jan 2011 07:57:36 -0600
Message-ID: <4D2DB350.1010509__11976.0754089386$1294840797$gmane$org@parallels.com>
References: <4D2BDE07.40202@parallels.com>	<20110111071239.GL29064@count0.beaverton.ibm.com>	<4D2C63B2.6090109@parallels.com>	<4D2C9BC6.7000402@parallels.com>
	<20110111163000.04d02a7f@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110111163000.04d02a7f-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 01/11/2011 03:30 PM, Jeff Layton wrote:
> I've got a patch queued that rearranges some fields in TCP_Server_Info
> according to pahole's recommendations. You may want to base this patch
> on that.

Queued where?

> It might also be good to run pahole on this after your patch to see if
> it might be better placed...

I put it right after the network address fields affected by it.  I can
stick it between:

        char *hostname; /* hostname portion of UNC string */
        struct socket *ssocket;

So that two consecutive pointers become three consecutive pointers.  But
again, I haven't seen what you did to the structure yet...

>>  	spin_lock(&cifs_tcp_ses_lock);
>>  	list_for_each_entry(server, &cifs_tcp_ses_list, tcp_ses_list) {
>> +		if (HAVE_NET_NS &&
>> +		    cifs_net_ns(server) != current->nsproxy->net_ns)
>> +			continue;
>> +
> 
> This HAVE_NET_NS thing is pretty ugly.

It's a compile time constant optimized away by the compiler, and cleanly
taking out the entire dependent clause with it when it's false (because
&& only evaluates the right side when the left side is true, meaning the
if can never trigger, thus dead code elimination).

How is that ugly?  It does exactly what it says.  I'm not sure what the
criteria are here.  (Was it better when it looked like a function rather
than a constant?  I'd use the CONFIG_NET_NS symbol directly if it was 0
or 1 rather than undefined or 1, but it isn't.  It's designed for use
with #ifdefs only, not from C code.)

> This is not a high-performance
> codepath. My vote would be to get rid of this and just have the useless
> test when CONFIG_NET_NS isn't set.
> 
> Alternately, you could turn the comparison into a static inline or
> macro, and simply have that compile down to nothing when CONFIG_NET_NS
> isn't set.

I tried returning a constant from a static inline, it doesn't propogate
the constant far enough to do compile time dead code elimination based
on the return value under gcc 4.4.3.

As for a macro, the constant already is a macro.  So adding more #ifdefs
to the headers to make the code in the function look like it's doing
something other than it actually is somehow improves matters?  (I'm not
understanding the aesthetic criteria here at all.)

I think I'll just ignore the bloat.  Make allnoconfig is already 800k
compressed, what's a few more bytes...

>> @@ -1754,6 +1762,8 @@ cifs_get_tcp_session(struct smb_vol *volume_info)
>>  out_err_crypto_release:
>>  	cifs_crypto_shash_release(tcp_ses);
>>  
>> +	put_net(cifs_net_ns(tcp_ses));
>> +
> 	^^^^
> This looks like it will oops if you end up doing the "goto
> out_err_crypto_release" after the extract_hostname call.

Hmmm...  Yup, failure case when CONFIG_NET_NS enabled will dereference
the null pointer.  I need to move the initialization up a few lines.
Thanks.

Rob
