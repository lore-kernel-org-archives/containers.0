From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] Modularize the handling of netdev address c/r
Date: Mon, 26 Apr 2010 08:11:14 -0700
Message-ID: <874oiyfdv1.fsf@caffeine.danplanet.com>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>
	<1270748932-26745-2-git-send-email-danms@us.ibm.com>
	<4BD4AE6D.2070507@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BD4AE6D.2070507-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Sun\, 25 Apr 2010 17\:04\:45 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


OL> Does this test-and-set need locking ?

No, I was just planning on getting lucky each time.  Er, okay, yes :)

>> +	if (try_module_get(h->owner))
>> +		return h;
>> +	else
>> +		return ERR_PTR(-EBUSY);

OL> Maybe some ckpt_err() here ?  I can feel the frustration of trying
OL> to figure out where _this_ came from !

I'd prefer not to do that this deep.  I think the varying depth at
which we call ckpt_err() starts to get confusing.  Regardless, the
call of this function is checked and reported, which I think will make
tracking down an error result rather easy:

  h = get_addr_handler(i);
  if (!h)
  	continue;
  else if (IS_ERR(h)) {
  	addrs = PTR_ERR(h);
  	ckpt_err(ctx, addrs,
  		 "Unable to handle netdev addr type %s\n",
  		 addr_modules[i]);
  	break;
  }

no?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
