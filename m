From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Linux-ima-devel] [RFC PATCH 1/5] ima: extend clone() with IMA
	namespace support
Date: Thu, 27 Jul 2017 16:51:58 -0400
Message-ID: <e14c46d1-fbc9-bfc7-a078-288141371e67__47418.657973367$1501188733$gmane$org@linux.vnet.ibm.com>
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
	<TU4PR84MB03025AD26718A173FB3E3F94FFBE0@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
	<3c3d8594-9958-5f53-ec0b-f33c36967f95@linux.vnet.ibm.com>
	<TU4PR84MB030243E7071B5A7455334886FFBE0@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <TU4PR84MB030243E7071B5A7455334886FFBE0-cn0wsXH2uUebani3oaRudNicc1VoeDReZmpNikb/MY7jO8Y7rvWZVA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Magalhaes, Guilherme (Brazil R&D-CL)" <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/27/2017 03:39 PM, Magalhaes, Guilherme (Brazil R&D-CL) wrote:
>
>> There's a vTPM proxy driver in the kernel that enables spawning a
>> frontend /dev/tpm%d and an anonymous backend file descriptor where a
>> vTPM can listen on for TPM commands. I integrated this with 'swtpm' and
>> I have been working on integrating this into runc. Currently each
>> container started with runc can get one (or multiple) vTPMs and
>> /dev/tpm0 [and /dev/tpmrm0 in case of TPM2] then appear inside the
>> container.
>>
> This is an interesting solution especially for nested namespaces with the
> recursive application of measurements and a having list per container.
>
> Following the TCG specs/requirements, what could we say about security
> guarantees of real TPMs Vs this vTPM implementation?


A non-root user may not be able to do access the (permanent) state of 
the vTPM state files since the container management stack would restrict 
access to the files using DAC. Access to runtime data is also prevented 
since the vTPM would not run under the account of the non-root user.

To protect the vTPM's permanent state file from access by a root user it 
comes down to preventing the root user from getting a hold of the key 
used for encrypting that file. Encrypting the state of the vTPM is 
probably the best we can do to approximate a temper-resistant chip, but 
preventing the root user from accessing the key may be more challenging.
Preventing root from accessing runtime data could be achieved by using 
XGS or a similar technology.

     Stefan
