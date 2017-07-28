From: "Magalhaes, Guilherme (Brazil R&D-CL)" <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>
Subject: RE: [Linux-ima-devel] [RFC PATCH 1/5] ima: extend clone() with IMA
	namespace support
Date: Fri, 28 Jul 2017 14:19:59 +0000
Message-ID: <TU4PR84MB03025BC4B8DEC44A0D63A298FFBF0__12626.5512466945$1501251626$gmane$org@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-2-mkayaalp@linux.vnet.ibm.com>
	<20170725175317.GA727@mail.hallyn.com>
	<1501008554.3689.30.camel@HansenPartnership.com>
	<20170725190406.GA1883@mail.hallyn.com>
	<1501009739.3689.33.camel@HansenPartnership.com>
	<1501012082.27413.17.camel@linux.vnet.ibm.com>
	<645db815-7773-e351-5db7-89f38cd88c3d@linux.vnet.ibm.com>
	<20170725204622.GA4969@mail.hallyn.com>
	<1501016277.27413.50.camel@linux.vnet.ibm.com>
	<20170725210801.GA5628@mail.hallyn.com>
	<1501018134.27413.66.camel@linux.vnet.ibm.com>
	<TU4PR84MB03021F7FDF1B89ECAA8F7FFFFFBE0@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
	<1501166369.28419.171.camel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1501166369.28419.171.camel-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> > Each measurement entry in the list could have new fields to identify
> > the namespace. Since the namespaces can be reused, a timestamp or
> > others fields could be added to uniquely identify the namespace id.
> 
> The more fields included in the measurement list, the more
> measurements will be added to the measurement list.  Wouldn't it be
> enough to know that a certain file has been accessed/executed on the
> system and base any analytics/forensics on the IMA-audit data.

With the recursive application of policy through the namespace hierarchy,
a measurement added to the parent namespace could be misleading since 
the file pathname makes sense in the current namespace but possibly not
for the parent namespace. This is the reason why I believe some new field
might be needed in the IMA template format to indicate or uniquely 
identify the namespace.

--
Guilherme
