From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH 23/29] memory controller memory accounting v7
Date: Thu, 13 Sep 2007 12:18:01 +0200
Message-ID: <1189678681.21778.191.camel@twins>
References: <20070911195239.997111000@menage.corp.google.com>
	<20070911200148.396756000@menage.corp.google.com>
	<1189630610.5597.10.camel@lappy> <46E9078D.5040908@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6071626698342603051=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46E9078D.5040908-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============6071626698342603051==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-9Ab4pv2XziY7iAocqYR9"


--=-9Ab4pv2XziY7iAocqYR9
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-09-13 at 15:19 +0530, Balbir Singh wrote:

> VM_BUG_ON(pc && !locked)

Even better :-)

> >> +/*
> >> + * Charge the memory controller for page usage.
> >> + * Return
> >> + * 0 if the charge was successful
> >> + * < 0 if the cgroup is over its limit
> >> + */
> >> +int mem_cgroup_charge(struct page *page, struct mm_struct *mm)
> >> +{
> >> +	struct mem_cgroup *mem;
> >> +	struct page_cgroup *pc, *race_pc;
> >> +
> >> +	/*
> >> +	 * Should page_cgroup's go to their own slab?
> >> +	 * One could optimize the performance of the charging routine
> >> +	 * by saving a bit in the page_flags and using it as a lock
> >> +	 * to see if the cgroup page already has a page_cgroup associated
> >> +	 * with it
> >> +	 */
> >> +	lock_page_cgroup(page);
> >> +	pc =3D page_get_page_cgroup(page);
> >> +	/*
> >> +	 * The page_cgroup exists and the page has already been accounted
> >> +	 */
> >> +	if (pc) {
> >> +		atomic_inc(&pc->ref_cnt);
> >> +		goto done;
> >> +	}
> >> +
> >> +	unlock_page_cgroup(page);
> >> +
> >> +	pc =3D kzalloc(sizeof(struct page_cgroup), GFP_KERNEL);
> >> +	if (pc =3D=3D NULL)
> >> +		goto err;
> >> +
> >> +	rcu_read_lock();
> >> +	/*
> >> +	 * We always charge the cgroup the mm_struct belongs to
> >> +	 * the mm_struct's mem_cgroup changes on task migration if the
> >> +	 * thread group leader migrates. It's possible that mm is not
> >> +	 * set, if so charge the init_mm (happens for pagecache usage).
> >> +	 */
> >> +	if (!mm)
> >> +		mm =3D &init_mm;
> >> +
> >> +	mem =3D rcu_dereference(mm->mem_cgroup);
> >> +	/*
> >> +	 * For every charge from the cgroup, increment reference
> >> +	 * count
> >> +	 */
> >> +	css_get(&mem->css);
> >> +	rcu_read_unlock();
> >> +
> >> +	/*
> >> +	 * If we created the page_cgroup, we should free it on exceeding
> >> +	 * the cgroup limit.
> >> +	 */
> >> +	if (res_counter_charge(&mem->res, 1)) {
> >> +		css_put(&mem->css);
> >> +		goto free_pc;
> >> +	}
> >> +
> >> +	lock_page_cgroup(page);
> >> +	/*
> >> +	 * Check if somebody else beat us to allocating the page_cgroup
> >> +	 */
> >> +	race_pc =3D page_get_page_cgroup(page);
> >> +	if (race_pc) {
> >> +		kfree(pc);
> >> +		pc =3D race_pc;
> >> +		atomic_inc(&pc->ref_cnt);
> >=20
> > This inc
> >=20
> >> +		res_counter_uncharge(&mem->res, 1);
> >> +		css_put(&mem->css);
> >> +		goto done;
> >> +	}
> >> +
> >> +	atomic_set(&pc->ref_cnt, 1);
> >=20
> > combined with this set make me wonder...
> >=20
>=20
> I am not sure I understand this comment.

Is that inc needed? the pc is already associated with the page and
should thus already have a reference, so this inc would do 1->2, but we
then set it to 1 again. seems like a superfluous operation.

--=-9Ab4pv2XziY7iAocqYR9
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG6Q5ZXA2jU0ANEf4RAuu/AJ90rHkxORAOvggqXsUXWTPhF0DpVwCePHnJ
yBYrTuhPd4D1Cvaht8vwrFA=
=SuWo
-----END PGP SIGNATURE-----

--=-9Ab4pv2XziY7iAocqYR9--


--===============6071626698342603051==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6071626698342603051==--
