From: "Magalhaes, Guilherme (Brazil R&D-CL)" <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>
Subject: RE: [Linux-ima-devel] [RFC PATCH 1/5] ima: extend clone() with IMA
	namespace support
Date: Thu, 27 Jul 2017 17:18:22 +0000
Message-ID: <TU4PR84MB03025AD26718A173FB3E3F94FFBE0__42869.930904317$1501175938$gmane$org@TU4PR84MB0302.NAMPRD84.PROD.OUTLOOK.COM>
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
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
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



> -----Original Message-----
> From: Mimi Zohar [mailto:zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org]
> Sent: quinta-feira, 27 de julho de 2017 11:39
> To: Magalhaes, Guilherme (Brazil R&D-CL)
> <guilherme.magalhaes-ZPxbGqLxI0U@public.gmane.org>; Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> Cc: Mehmet Kayaalp <mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org>; Yuqiong Sun
> <sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>; containers <containers-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> foundation.org>; linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; David Saffo=
rd
> <david.safford-JJi787mZWgc@public.gmane.org>; James Bottomley
> <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>; linux-security-module <linux-
> security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; ima-devel <linux-ima-
> devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>; Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: Re: [Linux-ima-devel] [RFC PATCH 1/5] ima: extend clone() with I=
MA
> namespace support
> =

> On Thu, 2017-07-27 at 12:51 +0000, Magalhaes, Guilherme (Brazil R&D-
> CL) wrote:
> >
> >
> > > On Tue, 2017-07-25 at 16:08 -0500, Serge E. Hallyn wrote:
> > > > On Tue, Jul 25, 2017 at 04:57:57PM -0400, Mimi Zohar wrote:
> > > > > On Tue, 2017-07-25 at 15:46 -0500, Serge E. Hallyn wrote:
> > > > > > On Tue, Jul 25, 2017 at 04:11:29PM -0400, Stefan Berger wrote:
> > > > > > > On 07/25/2017 03:48 PM, Mimi Zohar wrote:
> > > > > > > >On Tue, 2017-07-25 at 12:08 -0700, James Bottomley wrote:
> > > > > > > >>On Tue, 2017-07-25 at 14:04 -0500, Serge E. Hallyn wrote:
> > > > > > > >>>On Tue, Jul 25, 2017 at 11:49:14AM -0700, James Bottomley
> wrote:
> > > > > > > >>>>On Tue, 2017-07-25 at 12:53 -0500, Serge E. Hallyn wrote:
> > > > > > > >>>>>On Thu, Jul 20, 2017 at 06:50:29PM -0400, Mehmet Kayaalp
> > > wrote:
> > > > > > > >>>>>>
> > > > > > > >>>>>>From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > > > > > >>>>>>
> > > > > > > >>>>>>Add new CONFIG_IMA_NS config option.  Let clone() create
> a
> > > > > > > >>>>>>new IMA namespace upon CLONE_NEWNS flag. Add
> ima_ns
> > > data
> > > > > > > >>>>>>structure in nsproxy. ima_ns is allocated and freed upon
> > > > > > > >>>>>>IMA namespace creation and exit. Currently, the ima_ns
> > > > > > > >>>>>>contains no useful IMA data but only a dummy interface.
> > > > > > > >>>>>>This patch creates the framework for namespacing the
> > > different aspects of IMA (eg.
> > > > > > > >>>>>>IMA-audit, IMA-measurement, IMA-appraisal).
> > > > > > > >>>>>>
> > > > > > > >>>>>>Signed-off-by: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > > > > > >>>>>>
> > > > > > > >>>>>>Changelog:
> > > > > > > >>>>>>* Use CLONE_NEWNS instead of a new CLONE_NEWIMA
> flag
> > > > > > > >>>>>Hi,
> > > > > > > >>>>>
> > > > > > > >>>>>So this means that every mount namespace clone will clone
> a
> > > > > > > >>>>>new IMA namespace.  Is that really ok?
> > > > > > > >>>>Based on what: space concerns (struct ima_ns is reasonably
> > > small)?
> > > > > > > >>>>or whether tying it to the mount namespace is the correct
> > > > > > > >>>>thing to do.  On
> > > > > > > >>>Mostly the latter.  The other would be not so much space
> > > > > > > >>>concerns as time concerns.  Many things use new mounts
> > > > > > > >>>namespaces, and we wouldn't want multiple IMA calls on all
> > > > > > > >>>file accesses by all of those.
> > > > > > > >>>
> > > > > > > >>>>the latter, it does seem that this should be a property of
> > > > > > > >>>>either the mount or user ns rather than its own separate =
ns.
> > > > > > > >>>>I could see a use where even a container might want multi=
ple
> > > > > > > >>>>ima keyrings within the container (say containerised apac=
he
> > > > > > > >>>>service with multiple tenants), so instinct tells me that
> > > > > > > >>>>mount ns is the correct granularity for this.
> > > > > > > >>>I wonder whether we could use echo 1 >
> > > > > > > >>>/sys/kernel/security/ima/newns as the trigger for requesti=
ng
> > > > > > > >>>a new ima ns on the next clone(CLONE_NEWNS).
> > > > > > > >>I could go with that, but what about the trigger being
> > > > > > > >>installing or updating the keyring?  That's the only operat=
ion
> > > > > > > >>that needs namespace separation, so on mount ns clone, you
> get
> > > > > > > >>a pointer to the old ima_ns until you do something that
> > > > > > > >>requires a new key, which then triggers the copy of the
> namespace
> > > and installing it?
> > > > > > > >It isn't just the keyrings that need to be namespaced, but t=
he
> > > > > > > >measurement list and policy as well.
> > > > > > > >
> > > > > > > >IMA-measurement, IMA-appraisal and IMA-audit are all policy
> > > based.
> > > > > > > >
> > > > > > > >As soon as the namespace starts, measurements should be
> added
> > > > > > > >to the namespace specific measurement list, not it's parent.
> > > > > >
> > > > > > Shouldn't it be both?
> > > > >
> > > > > The policy defines which files are measured. =A0The namespace pol=
icy
> > > > > could be different than it's parent's policy, and the parent's
> > > > > policy could be different than the native policy. =A0Basically, f=
ile
> > > > > measurements need to be added to the namespace measurement
> list,
> > > > > recursively, up to the native measurement list.
> > > >
> > > > Yes, but if a task t1 is in namespace ns2 which is a child of
> > > > namespace ns1, and it accesses a file which ns1's policy says must =
be
> > > > measured, then will ns1's required measurement happen (and be
> > > appended
> > > > to the ns1 measurement list), whether or not ns2's policy requires =
it?
> > >
> > > Yes, as the file needs to be measured only in the ns1 policy, the
> > > measurement would exist in the ns1 measurement list, but not in the
> > > ns2 measurement list. =A0The pseudo code snippet below might help.
> >
> > This algorithm is potentially extending a PCR in TPM multiple times
> > for a single file event under a given namespace and duplicating
> > entries. Any concerns with performance and memory footprint?
> =

> Going forward we assume associated with each container will be a vTPM.
> The namespace measurements will extend a vTPM. =A0As the container comes
> and goes the associated measurement list, keyring, and vTPM will come
> and go as well. =A0For this reason, based on policy, the same file
> measurement might appear in multiple measurement lists.

My concern is that the base of namespacing the measurement lists is on the =

integration of containers with vTPM. Associating vTPM with containers as =

they are today is not a simple integration since vTPM requires a VM and =

containers do not. =

I cannot envision this association right now, but it might be possible afte=
r =

some research to understand the existent possibilities. For example, Intel =

SGX or clear containers may help with this integration. However, these
technologies have trade-offs which could restrict adoption.

--
Guilherme

> =

> > What is the reason to adding a measurement to multiple namespace
> > measurement lists? How are these lists going to be used? For Remote
> > Attestation we need a single list (the native one) which has the
> > complete list of measurements and in the same order they were
> > extended in the TPM. Additionally, when namespaces are released,
> > would the measurement list under that namespace disappear? How to
> > store this list considering the namespaces may have a short life and
> > be reused thousands of times?
> =

> Different scenarios have different requirements. =A0You're assuming that
> only the system owner is interested in the measurement list, not the
> container owner.
> =

> The current builtin measurement policies measure everything executed
> on the system and anything accessed by real root. =A0The namespace
> policy would probably be similar, but instead of measuring files
> accessed by real root, it would be files accessed by root in the
> namespace.
> =

> > Should the native measurement list have all measurements triggered
> > in the whole system, including the ones made under other namespaces?
> > Following the algorithm below, if the file is not in the policy of
> > the 'native'/initial namespace, the measurement is not added to the
> > native measurement list.
> =

> Correct. =A0The policy controls what is included measured, appraised,
> and audited.
> =

> > Each measurement entry in the list could have new fields to identify
> > the namespace. Since the namespaces can be reused, a timestamp or
> > others fields could be added to uniquely identify the namespace id.
> =

> The more fields included in the measurement list, the more
> measurements will be added to the measurement list. =A0Wouldn't it be
> enough to know that a certain file has been accessed/executed on the
> system and base any analytics/forensics on the IMA-audit data.
> =

> > Regarding namespace hierarchy and IMA policy, we could assume that
> > if a given namespace has no policy set, the policy of that namespace
> > parent is applied and then the native/initial namespace should
> > always have a set policy.
> =

> We shouldn't assume measure, appraise, or audit by default. =A0Just like
> it is up to the native system to define a policy or if there is a
> policy, the "container" owner should define the policy, or if there is
> a policy.
> =

> Mimi
> =

> > >
> > > do {
> > >    .
> > >    .
> > >
> > >    /* calculate file hash based on xattr algorithm */
> > >    collect_measurement()
> > >
> > >    /* recursively added to each namespace based on policy */
> > >    ima_store_measurement()
> > >
> > >    /* Based on the specific namespace policy and keys. */
> > >    if (!once) {
> > >        once =3D 1;
> > >        result =3D ima_appraise_measurement()
> > >    }
> > >
> > >    ima_audit_measurement()
> > >
> > > } while ((ns =3D ns->parent));
> > >
> > > return result;
> > >
> > > Mimi
