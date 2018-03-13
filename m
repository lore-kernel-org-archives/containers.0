From: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Subject: Re: [RFC PATCH 1/5] ima: extend clone() with IMA namespace support
Date: Wed, 14 Mar 2018 08:51:48 +1100 (AEDT)
Message-ID: <alpine.LRH.2.21.1803140851120.13609@namei.org>
References: <20170720225033.21298-1-mkayaalp@linux.vnet.ibm.com>
	<20170720225033.21298-2-mkayaalp@linux.vnet.ibm.com>
	<20170725175317.GA727@mail.hallyn.com>
	<1501008554.3689.30.camel@HansenPartnership.com>
	<20170725190406.GA1883@mail.hallyn.com>
	<1501009739.3689.33.camel@HansenPartnership.com>
	<1501012082.27413.17.camel@linux.vnet.ibm.com>
	<645db815-7773-e351-5db7-89f38cd88c3d@linux.vnet.ibm.com>
	<20170725204622.GA4969@mail.hallyn.com>
	<97839865-b0ab-8e5d-114e-0603ef2edf6f@linux.vnet.ibm.com>
	<20180309025942.GA15295@mail.hallyn.com>
	<ec137677-34f8-df91-0d1c-6c6d6c951496@linux.vnet.ibm.com>
	<alpine.LRH.2.21.1803120953310.26512@namei.org>
	<c39350db-046f-ea70-15e4-210884548b1e@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c39350db-046f-ea70-15e4-210884548b1e-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 13 Mar 2018, Stefan Berger wrote:

> On 03/11/2018 06:58 PM, James Morris wrote:
> > On Fri, 9 Mar 2018, Stefan Berger wrote:
> > 
> > > Yuqiong is publishing a paper in this area. I believe the conference is
> > > only
> > > later this year.
> > > 
> > > Our goals are to enable IMA measurements, appraisal, and auditing inside a
> > > container using namespaces.
> > This is excellent to have -- can you include this requirements analysis as
> > a file Documentation/security on the next posting?
> > 
> > Also, if you need a public space for managing these kinds of documents,
> > consider utilizing
> > http://kernsec.org/wiki/index.php/Linux_Kernel_Integrity
> 
> Thanks for the pointer. I tried creating an account, but the interface
> wouldn't let me. Who is managing it?

Email me for an account, per the note on the front page.


-- 
James Morris
<jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
