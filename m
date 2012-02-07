From: atp <Andrew.Phillips-xheW4WVAX9Y@public.gmane.org>
Subject: Re: cpu shielding.
Date: Tue, 07 Feb 2012 09:02:54 +0000
Message-ID: <1328605374.25682.5.camel@foo>
References: <1328536234.32188.49.camel@foo> <20120207021527.GA17937@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120207021527.GA17937@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge,

> I'm afraid I haven't been following recent upstream discussions on
> this, but there are other people who want proc to show cgroup-limited
> information.  See for instance http://lwn.net/Articles/460310/ .  Glauber
> has also brought this up since then.  I'd recommend pinging him.
> 
> I'm all for /proc showing cgroup-filtered information, unconditionally.
> 

 I'll check with him, and report back. Having looked at how openvz
handles this, it seems that to do this comprehensively - even just for
cpu shielding is not a quick fix.

 Andy

-- 
Andrew Phillips
Head of Systems

Direct: +44 (0)203 192 2509
Mobile: +44 (0)7595 242 900

LMAX, Yellow Building, 1A Nicholas Road,  London, W11 4AN



The information in this e-mail and any attachment is confidential and is intended only for the named recipient(s). The e-mail may not be disclosed or used by any person other than the addressee, nor may it be copied in any way. If you are not a named recipient please notify the sender immediately and delete any copies of this message. Any unauthorized copying, disclosure or distribution of the material in this e-mail is strictly forbidden. Any view or opinions presented are solely those of the author and do not necessarily represent those of the company.
