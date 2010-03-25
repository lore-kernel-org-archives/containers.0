From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] C/R: Support for IPv6 addresses on network devices
Date: Thu, 25 Mar 2010 14:01:21 -0700
Message-ID: <87aatwf74u.fsf@caffeine.danplanet.com>
References: <1269459625-21033-1-git-send-email-danms@us.ibm.com>
	<1269459625-21033-2-git-send-email-danms@us.ibm.com>
	<4BABC967.5090908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BABC967.5090908-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Thu\,
	25 Mar 2010 16\:36\:55 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

>> +#define HTON_IPV6(dst, src) __BYTE_ORDER_COPY(htonl, dst, src)
>> +#define NTOH_IPV6(dst, src) __BYTE_ORDER_COPY(ntohl, dst, src)

BH> Yuck, this is ugly, use ipv6_addr_copy() please.

So, I started with ipv6_addr_copy(), but that leaves the addresses in
the host endianess within the checkpoint image, right?  Dave Miller
had previously asked to have the IPv4 addresses htonl()'d before being
written to the image, so I was doing the same here.

BH> There was a new format specifier added to the kernel print
BH> routines called "%pI6" for printing IPv6 addresses.

Neato.  I didn't actually mean to leave those debug statements in
there, but I guess I will so I can use %pI6 :)

BH> When can this return value be < 0 other then -E2BIG?

It can't at the moment, but I figured I should catch it here now so
that the two checkpoint functions could throw an error later and not
have it go unnoticed.

>> +	ret = __kern_addrconf(net, SIOCSIFADDR, &req);
>> +	if (ret == -EEXIST)
>> +		ret = 0;
>> +	else if (ret < 0)
>> +		ckpt_err(ctx, ret, "Failed to set address");
>> +
>> +	return ret;
>> +}

BH> I am still worried about this.  When an interface is activated and
BH> the IPv6 module is loaded, it's going to generate a link-local address
BH> right away.  Then it will auto-configure an address based on information
BH> in a received router advertisement.  Is this code going to conflict
BH> with that?  Meaning, will you have two link-locals on this interface
BH> once the system is running?

I have to claim IPv6 ignorance here :)

BH> Also, moving these addresses around is going to increase the
BH> likelihood of a duplicate address (link-locals are typically based
BH> off the MAC, then the global uses the same lower 64-bits).  Maybe
BH> only saving/restoring "permanent" addresses is correct?

Sounds good to me :)

BH> There's also going to be some conflict when you get to adding the
BH> Multicast address back, as adding a "normal" IPv6 address is
BH> usually going to add at least one Multicast address in the
BH> process.

/me refers to his previous statement of ignorance.

BH> And what about tunnel devices?  Maybe you already cover that
BH> somewhere else?

Like sit devices?  If so, I punt on those right now (somewhere else).
I guess I need to add a patch to this set to save/restore their
addresses and attributes as well.

BH> And I won't harp on Anycast and Privacy addresses, I know this was
BH> only a first pass :)

I'll have to figure out how to test anycast, privacy, multicast and
link local addresses, as well as tunnel devices so that I can move
forward with some of these things.

Man, the world seems simpler with 32-bit addresses :)

Thanks Brian!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
