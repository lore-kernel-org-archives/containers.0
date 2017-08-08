From: "Magalhaes, Guilherme (Brazil R&D-CL)" <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>
Subject: Re: [Linux-ima-devel] [RFC PATCH 1/5] ima: extend clone() with IMA
Date: Tue, 8 Aug 2017 13:22:23 +0000
Message-ID: <TU4PR84MB0302CDE76E5E05075CF16A11FF8A0__38255.5639873773$1502198608$gmane$org@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>, Yuqiong Sun <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Safford <david.safford-JJi787mZWgc@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ima-devel <linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Stefan,
Still on the vTPM requirements, could you help answering the following
questions?

1. Where will the boot measurements be stored? What is the integrity 
measurement domain for this vTPM? The current proposal is that the 
vTPM would be used for the container (or namespace) files/inodes. 
What else will be available from the vTPM? For example, will the vTPM 
provide the UEFI measurements on the first PCRs (copied/proxied from 
physical TPM)?

2. From an attestation/quote perspective, how do you envision the key 
material to be managed (e.g. the vTPM EK and/or Attestation Key is 
fixed to the physical TPM, or it's cryptographically bound to it)?

3. Can you elaborate more on the alignment of this solution with the 
TCG requirements, especially considering the lack of isolation on the 
vTPM solution, do you have a future plan to cover those issues?

4. In a micro services pattern, or a serverless compute pattern, in 
which one or more containers are created to handle each individual 
request it is possible that there will be several thousand containers 
created per hour on a busy server. What is the expected performance 
and scalability of vTPMs within such an environment?

--
Guilherme

> -----Original Message-----
> From: Stefan Berger [mailto:stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org]
> Sent: quinta-feira, 27 de julho de 2017 17:52
> To: Magalhaes, Guilherme (Brazil R&D-CL) <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>;
> Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>; Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>; Yuqiong Sun
> <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>; containers <containers-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> foundation.org>; linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; David Safford
> <david.safford-JJi787mZWgc@public.gmane.org>; James Bottomley
> <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>; linux-security-module <linux-
> security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; ima-devel <linux-ima-
> devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>; Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: Re: [Linux-ima-devel] [RFC PATCH 1/5] ima: extend clone() with IMA
> namespace support
> 
> On 07/27/2017 03:39 PM, Magalhaes, Guilherme (Brazil R&D-CL) wrote:
> >
> >> There's a vTPM proxy driver in the kernel that enables spawning a
> >> frontend /dev/tpm%d and an anonymous backend file descriptor where a
> >> vTPM can listen on for TPM commands. I integrated this with 'swtpm' and
> >> I have been working on integrating this into runc. Currently each
> >> container started with runc can get one (or multiple) vTPMs and
> >> /dev/tpm0 [and /dev/tpmrm0 in case of TPM2] then appear inside the
> >> container.
> >>
> > This is an interesting solution especially for nested namespaces with the
> > recursive application of measurements and a having list per container.
> >
> > Following the TCG specs/requirements, what could we say about security
> > guarantees of real TPMs Vs this vTPM implementation?
> 
> 
> A non-root user may not be able to do access the (permanent) state of
> the vTPM state files since the container management stack would restrict
> access to the files using DAC. Access to runtime data is also prevented
> since the vTPM would not run under the account of the non-root user.
> 
> To protect the vTPM's permanent state file from access by a root user it
> comes down to preventing the root user from getting a hold of the key
> used for encrypting that file. Encrypting the state of the vTPM is
> probably the best we can do to approximate a temper-resistant chip, but
> preventing the root user from accessing the key may be more challenging.
> Preventing root from accessing runtime data could be achieved by using
> XGS or a similar technology.
> 
>      Stefan
> 
