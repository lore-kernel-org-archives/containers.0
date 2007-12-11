From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 1/2][NETNS][RFD] store the network namespace pointer in
	the dst_entry structure
Date: Tue, 11 Dec 2007 10:07:18 -0700
Message-ID: <m1myshyxbt.fsf@ebiederm.dsl.xmission.com>
References: <20071211131231.701104221@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071211131749.644219049@ICON-9-164-138-215.megacenter.de.ibm.com>
	<m1r6htz0sn.fsf@ebiederm.dsl.xmission.com>
	<475EB777.4070704@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <475EB777.4070704-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Tue,
	11 Dec 2007 17:14:47 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: xemul-3ImXcnM4P+0@public.gmane.org, den-3ImXcnM4P+0@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

>> Could you please place the struct net *net pointer up by the
>> network device pointer.
>>>  };
>>
>> I know we need a net pointer in struct rt_table, because it
>> is a hash table that we can't dynamically allocate so we need
>> to place a network namespace pointer as part of the hash key.
>>
>> For the ipv6 fib tables I don't recall needing a net pointer as we didn't have
>> a hash table and could instead have separate
>> roots for different namespaces.
>
> Yes don't need for the hash table but we used it to pass the network namespace
> parameter to the underlying function which need the net parameter.
>
> We are facing two problems when removing the fl_net field from flowi:
>
>  * The first one is the fl_net is used as a key. This problem can be handled
> simply in moving the netns to the rtable.

Yes.

>  * The second one is the usage made by the fl_net to pass through the different
> function calls the network namespace pointer without changing all functions
> signature. This problem can be solved if we put the netns pointer in the
> dst_entry structure, so when we are in ipv4, we use container_of on rtable and
> when we are in ipv6, we use the container_of on rt6_info. So everywhere with the
> flowi, we can retrieve the netns.

That doesn't work as rt6_info does not currently hold a struct flowi.

>> I find this slightly odd as I didn't wind up needing to add
>> a struct net pointer in struct dst in my proof of concept tree
>> and struct dst doesn't have a struct flowi so that would not
>> have prevented it.
>
> The idea is to put the net in the dst_entry because it is accessible from rtable
> or rt6_info and these ones contain a flowi field.

And since that isn't true, the idea seems to fall flat on it's face.

I expect most of the instances of struct flowi that we would be
looking things up with would be on the stack so the earlier concerns
raised would likely still need to be addressed.

Eric
