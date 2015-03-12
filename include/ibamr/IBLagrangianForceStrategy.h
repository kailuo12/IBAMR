// Filename: IBLagrangianForceStrategy.h
// Created on 03 May 2005 by Boyce Griffith
//
// Copyright (c) 2002-2014, Boyce Griffith
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//    * Redistributions of source code must retain the above copyright notice,
//      this list of conditions and the following disclaimer.
//
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//    * Neither the name of The University of North Carolina nor the names of
//      its contributors may be used to endorse or promote products derived from
//      this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#ifndef included_IBLagrangianForceStrategy
#define included_IBLagrangianForceStrategy

/////////////////////////////// INCLUDES /////////////////////////////////////

#include <vector>

#include "petscmat.h"
#include "boost/shared_ptr.hpp"

namespace IBTK
{
class LData;
class LDataManager;
} // namespace IBTK
namespace SAMRAI
{
namespace hier
{

class PatchHierarchy;
} // namespace hier
} // namespace SAMRAI

/////////////////////////////// CLASS DEFINITION /////////////////////////////

namespace IBAMR
{
/*!
 * \brief Class IBLagrangianForceStrategy provides a generic interface for
 * specifying nodal forces (\em not force densities) on the Lagrangian
 * curvilinear mesh.
 *
 * \note Implementations of class IBLagrangianForceStrategy must compute the
 * total nodal forces.  In particular, they \em must \em not compute the nodal
 * force densities.
 *
 * \see IBBeamForceGen
 * \see IBLagrangianForceStrategySet
 * \see IBSpringForceGen
 * \see IBStandardForceGen
 * \see IBTargetPointForceGen
 */
class IBLagrangianForceStrategy
{
public:
    /*!
     * \brief Default constructor.
     */
    IBLagrangianForceStrategy();

    /*!
     * \brief Virtual destructor.
     */
    virtual ~IBLagrangianForceStrategy();

    /*!
     * \brief Set the current and new times for the present timestep.
     *
     * \note A default empty implementation is provided.
     */
    virtual void setTimeInterval(double current_time, double new_time);

    /*!
     * \brief Setup the data needed to compute the curvilinear force on the
     * specified level of the patch hierarchy.
     *
     * \note A default empty implementation is provided.
     */
    virtual void initializeLevelData(boost::shared_ptr<SAMRAI::hier::PatchHierarchy> hierarchy,
                                     int level_number,
                                     double init_data_time,
                                     bool initial_time,
                                     IBTK::LDataManager* l_data_manager);

    /*!
     * \brief Compute the curvilinear force generated by the given configuration
     * of the curvilinear mesh.
     *
     * \note Nodal forces computed by implementations of this method must be \em
     * added to the force vector.
     *
     * \note A default implementation is provided that results in an assertion
     * failure.
     */
    virtual void computeLagrangianForce(boost::shared_ptr<IBTK::LData> F_data,
                                        boost::shared_ptr<IBTK::LData> X_data,
                                        boost::shared_ptr<IBTK::LData> U_data,
                                        boost::shared_ptr<SAMRAI::hier::PatchHierarchy> hierarchy,
                                        int level_number,
                                        double data_time,
                                        IBTK::LDataManager* l_data_manager);

    /*!
     * \brief Compute the non-zero structure of the force Jacobian matrix.
     *
     * \note Elements indices must be global PETSc indices.
     *
     * \note A default implementation is provided that results in an assertion
     * failure.
     */
    virtual void
    computeLagrangianForceJacobianNonzeroStructure(std::vector<int>& d_nnz,
                                                   std::vector<int>& o_nnz,
                                                   boost::shared_ptr<SAMRAI::hier::PatchHierarchy> hierarchy,
                                                   int level_number,
                                                   IBTK::LDataManager* l_data_manager);

    /*!
     * \brief Compute the Jacobian of the force with respect to the present
     * structure configuration and velocity.
     *
     * \note The elements of the Jacobian should be "accumulated" in the
     * provided matrix J.
     *
     * \note A default implementation is provided that results in an assertion
     * failure.
     */
    virtual void computeLagrangianForceJacobian(Mat& J_mat,
                                                MatAssemblyType assembly_type,
                                                double X_coef,
                                                boost::shared_ptr<IBTK::LData> X_data,
                                                double U_coef,
                                                boost::shared_ptr<IBTK::LData> U_data,
                                                boost::shared_ptr<SAMRAI::hier::PatchHierarchy> hierarchy,
                                                int level_number,
                                                double data_time,
                                                IBTK::LDataManager* l_data_manager);

    /*!
     * \brief Compute the potential energy with respect to the present structure
     * configuration and velocity.
     *
     * \note A default implementation is provided that results in an assertion
     * failure.
     */
    virtual double computeLagrangianEnergy(boost::shared_ptr<IBTK::LData> X_data,
                                           boost::shared_ptr<IBTK::LData> U_data,
                                           boost::shared_ptr<SAMRAI::hier::PatchHierarchy> hierarchy,
                                           int level_number,
                                           double data_time,
                                           IBTK::LDataManager* l_data_manager);

private:
    /*!
     * \brief Copy constructor.
     *
     * \note This constructor is not implemented and should not be used.
     *
     * \param from The value to copy to this object.
     */
    IBLagrangianForceStrategy(const IBLagrangianForceStrategy& from);

    /*!
     * \brief Assignment operator.
     *
     * \note This operator is not implemented and should not be used.
     *
     * \param that The value to assign to this object.
     *
     * \return A reference to this object.
     */
    IBLagrangianForceStrategy& operator=(const IBLagrangianForceStrategy& that);
};
} // namespace IBAMR

//////////////////////////////////////////////////////////////////////////////

#endif //#ifndef included_IBLagrangianForceStrategy
